# rakudo-bin
[![Build status](https://ci.appveyor.com/api/projects/status/rlkjded00sdnaep3?svg=true)](https://ci.appveyor.com/project/Prince213/rakudo-bin)

Build scripts and prebuilt Windows binaries for Rakudo.
## Prebuilt binaries
They are [here](https://ci.appveyor.com/project/Prince213/rakudo-bin).
## Contents
[Rakudo](https://github.com/rakudo/rakudo), [MoarVM](https://github.com/MoarVM/MoarVM), [NQP](https://github.com/Raku/nqp) and [zef](https://github.com/ugexe/zef).
## Building manually
You need to have MSVC tools and Perl 5 in your path.

Then simply run `pwsh .\BuildAndPackage.ps1`.
## Options
- `CoreVersion`: Version of Rakudo, NQP and MoarVM.
- `ZefVersion`: Version of Zef, the package manager.
- `KeepBuild`: Specify this option to keep build directories.
- `KeepSource`: Specify this option to keep sources.
- `Postfix`: Custom postfix for the created package.
