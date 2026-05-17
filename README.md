# package-resources-cli

[![CI](https://github.com/capturecontext/package-resources-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/capturecontext/package-resources-cli/actions/workflows/ci.yml) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fpackage-resources-cli%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/capturecontext/package-resources-cli) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fpackage-resources-cli%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/capturecontext/package-resources-cli)

Code generator for [swift-package-resources](https://github.com/capturecontext/swift-package-resources)

## Table of contents

- [Installation](#installation)
- [Usage](#usage)
- [Todos](#todos)
- [Alternatives](alternatives)
- [License](#license)

## Installation

1. Add required dependencies to your package

```swift
.package(
  url: "https://github.com/capturecontext/package-resources-cli.git", 
  .upToNextMajor(from: "4.0.0")
),
.package(
  url: "https://github.com/capturecontext/swift-package-resources.git", 
  .upToNextMajor(from: "5.0.0")
),
```

> [!Note]
>
> **Version update policy**
>
> Starting from `4.0.0` semver is only applied to CLI itself:
>
> - `major` updates are reserved for breaking config or output changes and major dependency updates
> - `minor` updates are reserved for additive changes in config or output
> - `patch` updates are reserved for other updates
>
> _`PackageResourcesClient` is treated as implementation details and changes in it's APIs are not subject to semantic versioning unless it involves changes in CLI behavior_

2. Add plugin and target dependency

```swift
.target(
  name: "AppUI",
  product: .library(.static),
  dependencies: [
    .product(
      name: "PackageResources",
      package: "swift-package-resources
    )
  ],
  resources: [...],
  plugins: [
    .plugin(
    	name: "package-resources-plugin",
      package: "package-resources-cli"
    ),
  ]
),
```

> [!TIP]
>
> _You can skip adding [swift-package-resources](https://github.com/capturecontext/swift-package-resources) dependency explicitly if you use exported alias instead:_
>
> ```swift
> .product(
>      name: "_ExportedPackageResources",
>      package: "package-resources-cli
> )
> ```
> 
> _it will still work as_ `import PackageResources`

### Makefile

Make allows you to build and install `package-resources-cli` globally or locally, if you don't want to use swiftpm plugin

```bash
# Download repo
git clone https://github.com/capturecontext/package-resources-cli.git

# Navigate to repo directory
cd package-resources-cli

# Build and install globally using `make install`
# or see Makefile for more options
make install

# You can also delete package-resources-cli using `make uninstall` command
```

## Usage

Supported resource types:

| Resource            | Extensions        | Is reliable     |
| ------------------- | ----------------- | --------------- |
| _ColorResource      | `.xcassets`       | yes             |
| _FontResource       | `.ttf` `.otf`     | yes             |
| _ImageResource      | `.xcassets`       | yes             |
| _SCNSceneResource   | `.scnassets/.scn` | yes             |
| _XCStringResource   | `xcstrings`       | yes             |
| _NibResource        | `.xib`            | not used/tested |
| _StoryboardResource | `.storyboard`     | not used/tested |

> [!WARNING]
>
> **Fonts require additional setup**
>
> For example you want to add `Monsterrat` and `Arimo` fonts with different styles
>
> - Download fonts and add them to your resources folder
>
> - Add a static factories for your custom fonts (_[Example](https://gist.github.com/maximkrouk/5bcccc5db12f0347676be5a776c309a8)_)
> - Register custom fonts on app launch (_in AppDelegate, for example_) 
>   - `UIFont.bootstrap()` if you are using code from the example above.

✅ Except of some hectic with fonts, installation is enough for using the plugin with [swift-package-resources](https://github.com/capturecontext/swift-package-resources).

### Configuration

Package plugin uses `.packageresources` file at the root of the package with as it's configuration file

```yml
version: "4.0"
output: "<path-to-output-file>"
indentor: "\t"
indent-size: 1
access-level: internal
group-by-catalog: true
numbers:
  separator: "_"
  allowed-delimeters: []
  next-token-mode: inherit
  ending-number-boundary-options:
  - disable-token-processing
  single-letter-boundary-options:
  - disable-separators
  - disable-token-processing
colors:
  group-by-folders: true
  split-by-key-path: true
images: default
fonts:
  ignore: false
nibs:
  ignore: true
scn-scenes:
  group-by-folders: true
  split-by-key-path: true
storyboards:
  ignore: true
xcstrings:
  split-by-key-path: true
acronyms:
  processing-policy: default
  values:
  - id
  - ID
  - Id
  ...
```

> [!Tip]
>
> _Use **package-specific configs** for your defaults and **target-specific configs** for separate targets, this way it's possible to expose shared resources from your design-system target and allow for local resources in feature targets._ 

In v4 all resource types are enabled by default. Disable a type with `ignore: true` in its section instead of using `resource-types`.

Top-level format keys are shared defaults. Resource sections inherit omitted values from the root config unless the section is set to the `default` alias, which uses the built-in defaults.

| Argument                                 | Description                                                  |
| ---------------------------------------- | ------------------------------------------------------------ |
| `version`                                | Manifest format version. Current version is `4.0`.           |
| `output`                                 | Path to output file. <br />Default is dynamically calculated as `input` + `/Resources.generated.swift` |
| `indentor`                               | Indentation symbol. <br />Default is `\t`                    |
| `indent-size`                            | Amount of indentors per indent level. <br />`default` is `1`<br />`default` for `space`/`whitespace`/`" "`  indentors is `2` |
| `access-level`                           | Access level for generated declarations (`private`, `internal`, `package`, `public`, or `none`). <br />Default is `internal` |
| `group-by-catalog`                       | Whether catalog-backed resources are nested under a catalog-name enum. Applies to colors, images, SCN scenes, and xcstrings unless overridden. <br />Default is `true` |
| `<resource>.ignore`                      | Disables a resource type when `true`. Resource sections are `colors`, `images`, `fonts`, `nibs`, `scn-scenes`, `storyboards`, and `xcstrings`. <br />Default is `false` |
| `<resource>.group-by-catalog`            | Overrides catalog grouping for one resource section. Supported by `colors`, `images`, `scn-scenes`, and `xcstrings`. |
| `<resource>.group-by-folders`            | Groups folders inside asset catalogs into nested enums. Supported by `colors`, `images`, and `scn-scenes`. <br />Default is `true` |
| `<resource>.split-by-key-path`           | Splits dotted names/keys into nested enums. Supported by `colors`, `images`, `scn-scenes`, and `xcstrings`. <br />Default is `true` |
| `numbers.separator`                      | Separator for numeric values.<br />`default` is `"_"`        |
| `numbers.allowed-delimeters`             | Extends allowed characters for numbers, specifying `["."]` might be helpful for enabling `FloatingPoint` numbers, however it's only allowed delimiter, so with this setting `"1.2.3_value"` will be tokenized as `["1.2.3", "_", "value"]`<br />`default` is `[]` |
| `numbers.next-token-mode`                | Camel case mode for a token after a number.<br />`default` is `inherit` (equivalent to `automatic`) |
| `numbers.ending-number-boundary-options` | Options for numeric boundaries at ending number tokens (`disable-separators`, `disable-token-processing`, `none`, `current`, `default`). |
| `numbers.single-letter-boundary-options` | Options for numeric boundaries around single-letter tokens (`disable-separators`, `disable-token-processing`, `none`, `current`, `default`). |
| `acronyms.processing-policy`             | See [CamelCaseConfig.Acronyms.ProcessingPolicy](https://github.com/CaptureContext/swift-casification/blob/main/Sources/Casification/Configuration/CamelCase/CamelCaseConfig.swift).<br />`default` is `always-match-case`. |
| `acronyms.values`                        | Overrides all default acronyms.<br />`default` can be found [here](https://github.com/CaptureContext/swift-casification/blob/main/Sources/Casification/Configuration/Common/Acronyms/AcronymsConfig.swift). |

`resource-types` and `group-xcstrings-by-catalog-name` are still decoded for v1-v3 manifests. In v4, use resource `ignore` flags and `xcstrings.group-by-catalog`.

### Command plugin

You can run commands manually using `swift package resources`

#### Generate command

```bash
swift package resources generate \
  --input "<path-to-lookup-root>" \
  --config "<path-to-configuration-file>" \
  --output "<path-to-output-file>" \
  --indentor "\t" \
  --indent-size 1 \
  --access-level internal \
  --group-by-catalog \
  --no-ignore-colors \
  --no-ignore-images \
  --ignore-nibs \
  --ignore-storyboards \
  --colors-group-by-folders \
  --images-group-by-folders \
  --scn-scenes-group-by-folders \
  --xcstrings-split-by-key-path \
  --numbers-separator "_" \
  --numbers-allowed-delimeters "__package_resources_unspecified" \
  --numbers-next-token-mode inherit \
  --numbers-ending-number-boundary-options default \
  --numbers-single-letter-boundary-options default \
  --acronyms-processing-policy default \
  --acronyms-values "acronym1" "acronym2"
```

#### Config init command

Dumps default configuration into a config file at the root of the package

```bash
swift package resources config init --format yaml # `json` is also supported
swift package resources config init --force # rewrite config file
```

#### Config edit command

Utility for editing config files, overrides specific values in config file

```bash
swift package resources config edit \
  --indentor "\s" \
  --indent-size 2
```

Also can remove specific keys from the config, just pass `--remove-` prefixed arguments as flags

```bash
swift package resources config edit --remove-acronyms-values
```

> [!TIP]
>
> _Path to config file can be specified for config commands_
>
> ```bash
> swift package resources config \
>      --path "<path-to-config-file>" \
>      edit --remove-output
> ```

## Todos

- [ ] Improve docs

> [!TIP]
>
> _You can find docc reference generated by swift-argument-parser [here]( .github/package-resources-cli.md)_

- [ ] Excludes support
- [ ] Filesystem expressions support
- [ ] Resources validation
- [ ] Images optimizations
- [ ] Legacy strings support

## Alternatives

- [swiftgen/swiftgen](https://github.com/swiftgen/swiftgen) – Generic codegen
- [mac-cain13/r.swift](https://github.com/mac-cain13/r.swift) – Codegen for resources
- [liamnichols/xcstrings-tool](https://github.com/liamnichols/xcstrings-tool/) – Localized strings
- Xcode supports generating internal symbols from resources out of the box

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
