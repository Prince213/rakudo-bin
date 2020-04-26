# rakudo-bin
Build scripts and prebuilt binaries for Rakudo.
## Usage
You need to have MSVC tools and Perl 5 in your path.

Then simply run `pwsh .\BuildAndPackage.ps1` will do the rest.
## Options
CoreVersion: Version of Rakudo, nqp and MoarVM.

ZefVersion: Version of Zef, the package manager.

KeepBuild: Specify this option to keep build directories.

KeepSource: Specify this option to keep sources.
