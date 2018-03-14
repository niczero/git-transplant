# Git Transplant

## Description

Git transplant copies a chain of (one or more) commits onto the current branch
replicating file state.  Optionally it can also set the author, author-date, and
commmitter-date.

There are two main applications for this: first, to transpose commits faithfully
from one development path to the current branch, avoiding any tangled discussion
about merges; and second, to (re)build a development path and then use git
transplant to restore the date timestamps.

## Installation

1. Copy ```bin/git-transpose``` to a location for local executables (on your
   PATH).

```sh
  cp bin/git-tranpose /usr/local/bin/
  chmod a+x /usr/local/bin/git-transpose
```

2. Copy ```man/git-transpose.1``` to a location for local manual pages.

```sh
  gzip <man/git-tranpose.1 >/usr/local/share/man/man1/git-transpose.1.gz
```

3. Test

```sh
  git transpose --help
  git tran<tab>
```

If you have tab-completion working for git commands, it should also work for
this new command.

## Copyright and Licence

Copyright (c) 2017--2018 Nic Sandfield.  All rights reserved.

This program is free software, you can redistribute it and/or modify it under
the terms of the MIT Licence.
