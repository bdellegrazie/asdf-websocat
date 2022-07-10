<div align="center">

# asdf-websocat [![Build](https://github.com/bdellegrazie/asdf-websocat/actions/workflows/build.yml/badge.svg)](https://github.com/bdellegrazie/asdf-websocat/actions/workflows/build.yml) [![Lint](https://github.com/bdellegrazie/asdf-websocat/actions/workflows/lint.yml/badge.svg)](https://github.com/bdellegrazie/asdf-websocat/actions/workflows/lint.yml)


[websocat](https://github.com/vi/websocat) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `ASDF_WEBSOCAT_VERSION`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add websocat
# or
asdf plugin add websocat https://github.com/bdellegrazie/asdf-websocat.git
```

websocat:

*WARNING*: due to release naming changes in the source project this plugin only supports releases `v1.10.0` or higher.

However, as a work-around for version issues or platform detection failure, you can override the "target" part of the URL below
by setting the environment variable `ASDF_WEBSOCAT_DISTRO` to the desired target. Platform auto-detection is difficult and there
might be bugs here - please raise an issue on GitHub if yours is detected incorrectly.

```shell
"$GH_REPO/releases/download/v${version}/${target}"
```

```shell
# Show all installable versions
asdf list-all websocat

# Install specific version
asdf install websocat latest

# Set a version globally (on your ~/.tool-versions file)
asdf global websocat latest

# Now websocat commands are available
websocat --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/bdellegrazie/asdf-websocat/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [<YOUR NAME>](https://github.com/bdellegrazie/)
