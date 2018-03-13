# Git Transplant

## DESCRIPTION

Git transplant copies a chain of (one or more) commits onto the current branch
replicating file state.  Optionally it can also set the author, author-date, and
commmitter-date.

There are two main applications for this: first, to transpose commits faithfully
from one development path to the current branch, avoiding any tangle of
discussion about merges; and second, to (re)build a development path and then
use git transplant to restore the date timestamps.

## INSTALLATION

1. Copy bin/git-transpose to your git installation directory.

  cp bin/git-tranpose /usr/lib/git-core/

2. Copy man/git-transpose.1 to your git manual pages.

  gzip <man/git-tranpose.1 >/usr/share/man/man1/git-transpose.1.gz

## COPYRIGHT AND LICENCE

Copyright (c) 2017--2018 Nic Sandfield.  All rights reserved.

This program is free software, you can redistribute it and/or modify it under
the terms of the MIT Licence.
