# package-resources-cli

[![CI](https://github.com/capturecontext/package-resources-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/capturecontext/package-resources-cli/actions/workflows/ci.yml) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fpackage-resources-cli%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/capturecontext/package-resources-cli) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fpackage-resources-cli%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/capturecontext/package-resources-cli)

Code generator for [swift-package-resources](https://github.com/capturecontext/swift-package-resources)

## Table of contents

- [Installation](#installation)
- [Usage](#usage)
- [Todos](#todos)
- [License](#license)

## Installation

1. Add required dependencies to your package

```swift
.package(
  url: "https://github.com/capturecontext/package-resources-cli.git", 
  .upToNextMajor(from: "2.0.0")
),
.package(
  url: "https://github.com/capturecontext/swift-package-resources.git", 
  .upToNextMajor(from: "4.0.0")
),
```

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

| Resource           | Extensions        | Is reliable     |
| ------------------ | ----------------- | --------------- |
| ColorResource      | `.xcassets`       | yes             |
| FontResource       | `.ttf` `.otf`     | yes             |
| ImageResource      | `.xcassets`       | yes             |
| SCNSceneResource   | `.scnassets/.scn` | yes             |
| NibResource        | `.xib`            | not used/tested |
| StoryboardResource | `.storyboard`     | not used/tested |

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
output: "<path-to-output-file>"
indentor: "\t"
indent-size: 1
numbers:
  separator: "_"
  allowed-delimeters: []
  next-token-mode: inherit
  single-letter-boundary-options:
  - disable-separators
  - disable-next-token-processing
acronyms:
  processing-policy: default
  values
  - id
  - ID
  - Id
  ...
```

| Argument                                 | Description                                                  |
| ---------------------------------------- | ------------------------------------------------------------ |
| `output`                                 | Path to output file. <br />Default is dynamically calculated as `input` + `/Resources.generated.swift` |
| `indentor`                               | Indentation symbol. <br />Default is `\t`                    |
| `indent-size`                            | Amount of indentors per indent level. <br />`default` is `1`<br />`default` for `space`/`whitespace`/`" "`  indentors is `2` |
| `numbers.separator`                      | Separator for numeric values.<br />`default` is `"_"`        |
| `numbers.allowed-delimeters`             | Extends allowed characters for numbers, specifying `["."]` might be helpful for enabling `FloatingPoint` numbers, however it's only allowed delimiter, so with this setting `"1.2.3_value"` will be tokenized as `["1.2.3", "_", "value"]`<br />`default` is `[]` |
| `numbers.next-token-mode`                | Camel case mode for a token after a number.<br />`default` is `inherit` (equivalent to `automatic`) |
| `numbers.single-letter-boundary-options` | Options for numeric boundary with single letter tokens.<br />Both options are enabled by `default` |
| `acronyms.processing-policy`             | See [CamelCaseConfig.Acronyms.ProcessingPolicy](https://github.com/CaptureContext/swift-casification/blob/main/Sources/Casification/Configuration/CamelCase/CamelCaseConfig.swift).<br />`default` is `always-match-case`. |
| `acronyms.values`                        | Overrides all default acronyms.<br />`default` can be found [here](https://github.com/CaptureContext/swift-casification/blob/main/Sources/Casification/Configuration/Common/Acronyms/AcronymsConfig.swift). |

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
  --numbers-separator "_" \
  --numbers-allowed-delimeters "__package_resources_unspecified" \
  --numbers-next-token-mode inherit \
  --numbers-single-letter-boundary-options default \
  --acronyms-processing-policy default \
  --acronyms-values "acronym1" "acronym2"
```

#### Config init command

Dumps default configuration into a config file

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

- [ ] Localized strings support
- [ ] Excludes support
- [ ] Filesystem expressions support
- [ ] Resources validation

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
