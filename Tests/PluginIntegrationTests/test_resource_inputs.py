#!/usr/bin/env python3
"""Exercise the production plugin's incremental build inputs without remote dependencies.

The tiny tool records fixture contents instead of invoking resource processors, isolating
SwiftPM invalidation from generator behavior and dependency resolution.
"""

from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]


class ResourceInputsTests(unittest.TestCase):
    def test_edits_additions_removals_and_package_configuration(self):
        self.check_inputs()

    def test_package_root_target_excludes_build_outputs(self):
        self.check_inputs(target_root=True)

    def test_package_root_target_excludes_custom_scratch_outputs(self):
        self.check_inputs(target_root=True, scratch_path="build-output")

    def check_inputs(self, target_root=False, scratch_path=".build"):
        with tempfile.TemporaryDirectory(prefix="package-resource-inputs-") as temporary:
            root = Path(temporary)
            plugin = root / "Plugins/Resources/plugin.swift"
            plugin.parent.mkdir(parents=True)
            shutil.copyfile(ROOT / "Plugins/package-resources-plugin/plugin.swift", plugin)
            (root / "Package.swift").write_text('''// swift-tools-version: 6.1
import PackageDescription
let package = Package(
    name: "ResourceInputFixture",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(name: "package-resources-cli"),
        .plugin(name: "Resources", capability: .buildTool(), dependencies: ["package-resources-cli"]),
        .target(name: "Fixture", resources: [.copy("Resources")], plugins: ["Resources"]),
    ]
)
''')
            if target_root:
                manifest = root / "Package.swift"
                manifest.write_text(manifest.read_text().replace(
                    '.target(name: "Fixture", resources: [.copy("Resources")],',
                    '.target(name: "Fixture", path: ".", '
                    'exclude: ["Plugins", "Sources/package-resources-cli", "Package.swift"], '
                    'resources: [.copy("Sources/Fixture/Resources")],',
                ))
            if target_root and scratch_path != ".build":
                # Keep SwiftPM source discovery valid; plugin input traversal must also exclude it.
                manifest.write_text(manifest.read_text().replace(
                    '"Package.swift"]', f'"Package.swift", "{scratch_path}"]',
                ))
            tool = root / "Sources/package-resources-cli/main.swift"
            tool.parent.mkdir(parents=True)
            tool.write_text(r'''import Foundation
let arguments = CommandLine.arguments
func argument(_ name: String) -> String { arguments[arguments.firstIndex(of: name)! + 1] }
let input = URL(fileURLWithPath: argument("--input"))
let rootResources = input.appending(path: "Sources/Fixture/Resources")
let resources = FileManager.default.fileExists(atPath: rootResources.path)
    ? rootResources : input.appending(path: "Resources")
let files = FileManager.default.enumerator(at: resources, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])!
var values: [String] = []
for case let file as URL in files where file.pathExtension == "txt" {
    values.append(try String(contentsOf: file, encoding: .utf8))
}
if arguments.contains("--config") {
    values.append(try String(contentsOfFile: argument("--config"), encoding: .utf8))
}
let snapshot = values.sorted().joined(separator: "|")
try "public let resourceSnapshot = \(String(reflecting: snapshot))\n"
    .write(toFile: argument("--output"), atomically: true, encoding: .utf8)
''')
            resources = root / "Sources/Fixture/Resources"
            resources.mkdir(parents=True)
            (resources.parent / "Fixture.swift").write_text("public enum Fixture {}\n")
            original = resources / "original.txt"
            original.write_text("first")
            configuration = root / ".packageresources"
            configuration.write_text("config-first")

            def build_snapshot():
                result = subprocess.run(
                    ["swift", "build", "--scratch-path", str(root / scratch_path), "--target", "Fixture", "--build-system", "native"],
                    cwd=root, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                )
                self.assertEqual(result.returncode, 0, result.stdout)
                generated = list((root / scratch_path / "plugins/outputs").rglob("Resources.generated.swift"))
                self.assertEqual(len(generated), 1)
                return generated[0].read_text()

            self.assertIn('"config-first|first"', build_snapshot())
            original.write_text("edited")
            self.assertIn('"config-first|edited"', build_snapshot())
            added = resources / "added.txt"
            added.write_text("added")
            self.assertIn('"added|config-first|edited"', build_snapshot())
            original.unlink()
            self.assertIn('"added|config-first"', build_snapshot())
            configuration.write_text("config-edited")
            self.assertIn('"added|config-edited"', build_snapshot())


if __name__ == "__main__":
    unittest.main()
