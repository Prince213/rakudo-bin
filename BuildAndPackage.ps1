# Copyright 2020 Sizhe Zhao
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
[CmdletBinding()]
param (
    [string]$CoreVersion = '2020.02.1',
    [string]$ZefVersion = '0.8.3',
    [switch]$KeepBuild = $False,
    [switch]$KeepSource = $False
)

Write-Host "Checking for necessary programs"

where.exe /Q cl.exe
if (-not $?) {
    Write-Error "Can't locate cl."
    exit 1
}

where.exe /Q perl.exe
if (-not $?) {
    Write-Error "Can't locate perl."
    exit 1
}

Write-Host "Preparing sources"

if (!(Test-Path -Path "MoarVM-$CoreVersion" -PathType Container)) {
    if (!(Test-Path -Path "MoarVM-$CoreVersion.tar.gz" -PathType Leaf)) {
        Invoke-WebRequest -Uri "https://github.com/MoarVM/MoarVM/releases/download/$CoreVersion/MoarVM-$CoreVersion.tar.gz" -OutFile "MoarVM-$CoreVersion.tar.gz"
    }
    where.exe /Q tar.exe
    if (-not $?) {
        Write-Error "Can't locate tar. You can get one from libarchive."
        exit 1
    }
    tar.exe xf "MoarVM-$CoreVersion.tar.gz"
}

if (!(Test-Path -Path "nqp-$CoreVersion" -PathType Container)) {
    if (!(Test-Path -Path "nqp-$CoreVersion.tar.gz" -PathType Leaf)) {
        Invoke-WebRequest -Uri "https://github.com/Raku/nqp/releases/download/$CoreVersion/nqp-$CoreVersion.tar.gz" -OutFile "nqp-$CoreVersion.tar.gz"
    }
    where.exe /Q tar.exe
    if (-not $?) {
        Write-Error "Can't locate tar. You can get one from libarchive."
        exit 1
    }
    tar.exe xf "nqp-$CoreVersion.tar.gz"
}

if (!(Test-Path -Path "rakudo-$CoreVersion" -PathType Container)) {
    if (!(Test-Path -Path "rakudo-$CoreVersion.tar.gz" -PathType Leaf)) {
        Invoke-WebRequest -Uri "https://github.com/rakudo/rakudo/releases/download/$CoreVersion/rakudo-$CoreVersion.tar.gz" -OutFile "rakudo-$CoreVersion.tar.gz"
    }
    where.exe /Q tar.exe
    if (-not $?) {
        Write-Error "Can't locate tar. You can get one from libarchive."
        exit 1
    }
    tar.exe xf "rakudo-$CoreVersion.tar.gz"
}

if (!(Test-Path -Path "zef-$ZefVersion" -PathType Container)) {
    if (!(Test-Path -Path "zef-$ZefVersion.tar.gz" -PathType Leaf)) {
        Invoke-WebRequest -Uri "https://github.com/ugexe/zef/archive/v$ZefVersion.tar.gz" -OutFile "zef-$ZefVersion.tar.gz"
    }
    where.exe /Q tar.exe
    if (-not $?) {
        Write-Error "Can't locate tar. You can get one from libarchive."
        exit 1
    }
    tar.exe xf "zef-$ZefVersion.tar.gz"
}

# Need to patch MoarVM-2020.02.1
if ("x$CoreVersion" -eq "x2020.02.1") {
    where.exe /Q sed.exe
    if (-not $?) {
        Write-Error "Can't locate sed. You can get one from MSYS2."
        exit 1
    }
    # See https://github.com/libtom/libtommath/pull/484
    sed.exe -i -e "s@if defined@if defined(_M_IX86) || defined@" "MoarVM-$CoreVersion/3rdparty/libtommath/bn_mp_set_double.c"
}

Write-Host "Building"

$BuildRoot = Get-Location

# Make nqp and rakudo recognize nmake in non-English environment.
chcp.com 437

Set-Location "MoarVM-$CoreVersion"
perl.exe ./Configure.pl --os win32 --shell win32 --toolchain msvc --compiler cl --prefix "$BuildRoot/prefix" --relocatable
nmake.exe install
Set-Location ..

Set-Location "nqp-$CoreVersion"
perl.exe ./Configure.pl "--prefix=$BuildRoot/prefix" --backends=moar "--with-moar=$BuildRoot/prefix/bin/moar.exe" --make-install
Set-Location ..

Set-Location "rakudo-$CoreVersion"
perl.exe ./Configure.pl "--prefix=$BuildRoot/prefix" --relocatable --backends=moar "--with-nqp=$BuildRoot/prefix/bin/nqp.exe" --make-install
Set-Location ..

Set-Location "zef-$ZefVersion"
& "$BuildRoot/prefix/bin/raku.exe" -I . bin/zef install .
Set-Location ..

Write-Host "Packaging"

Compress-Archive prefix\* -DestinationPath "rakudo-$CoreVersion.zip"

Write-Host "Cleaning up"

Remove-Item -Recurse prefix

if (!$KeepBuild) {
    Remove-Item -Recurse "MoarVM-$CoreVersion"
    Remove-Item -Recurse "nqp-$CoreVersion"
    Remove-Item -Recurse "rakudo-$CoreVersion"
    Remove-Item -Recurse "zef-$ZefVersion"
}

if (!$KeepSource) {
    Remove-Item "MoarVM-$CoreVersion.tar.gz"
    Remove-Item "nqp-$CoreVersion.tar.gz"
    Remove-Item "rakudo-$CoreVersion.tar.gz"
    Remove-Item "zef-$ZefVersion.tar.gz"
}

Write-Host "Build succeeded"
