# auru: A shell script for keeping AUR packages up-to-date


Author: Nicolas Carolo <nicolascarolo.dev@gmail.com>

Copyright: © 2020, Nicolas Carolo.

Date: 2020-03-19

Version: 0.1.0


## PURPOSE

_auru_ is a simple shell script for keeping AUR packages up-to-date on Arch Linux. You can use this tool instead of making manually the pull of the git repositories of the AUR packages.

### Features

* Check for new updates
* Possibility of install new updates

## MINIMUM REQUIREMENTS

### Supported OS

* Arch Linux
* Linux distributions based on Arch Linux

### Dependencies

* git

## INSTALLATION

We can install _auru_ simply by doing:
```sh
$ git clone https://github.com/nicolas-carolo/auru
$ cd auru
$ sudo chmod +x install.sh
$ sudo sh install.sh
```

## USAGE

For a list of all commands you can run and for the relative functionalities run:

```sh
$ man auru
```


## COPYRIGHT

Copyright © 2020, Nicolas Carolo.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions, and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions, and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

3. Neither the name of the author of this software nor the names of
   contributors to this software may be used to endorse or promote
   products derived from this software without specific prior written
   consent.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
