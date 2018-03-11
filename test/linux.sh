#!/bin/bash

set -e -u

declare -r  PROG="${0##*/}"
declare -r  TEMPDIR="$(mktemp -d -t git-copy.XXXXXXXX)"
declare -rx GIT_DIR="$TEMPDIR"/.git
declare -r  GCS=bin/git-transplant

function clean_up { rm -rf "$TEMPDIR"; }

function log { echo ": $*" >&2; }

function fail { log "$PROG: ${1:-"Unanticipated error"}"; clean_up; exit 1; }
trap fail ERR

[ -x "$GCS" ] \
  && log 'Found executable' || fail 'Test from the base directory'

git init .
git commit --allow-empty -mZero \
  --date='2001-01-01 10:10:10' --author='Robin <robin@ttitans.com>'
git branch -m master B
git branch A
git commit --allow-empty -mOne \
  --date='2002-02-02 10:10:10' --author='Raven <raven@ttitans.com>'
GIT_COMMITTER_DATE='2003-04-04 11:11:11' git commit --allow-empty -mTwo \
  --date='2003-03-03 10:10:10' --author='Starfire <starfire@ttitans.com>'
log 'Created initial commits' && sleep 1

log 'Test option: author'
git checkout -b C A
"$GCS" --author='Cyborg <cyborg@ttitans.com>' A B
x="$(git log -1 --pretty=%an B)"
[ "$x" == 'Starfire' ] \
  && log 'Correct author' || fail "Wrong author ($x)"
x="$(git log -1 --pretty=%an C)"
[ "$x" == 'Cyborg' ] \
  && log 'Correct author' || fail "Wrong author ($x)"

log 'Test option: date'
git checkout -b D A
"$GCS" --date='1999-12-31 23:59:59' A B
x="$(git log -1 --pretty=%ai B | cut -d' ' -f1)"
[ "$x" == 2003-03-03 ] \
  && log 'Correct author date' || fail "Wrong author date ($x)"
x="$(git log -1 --pretty=%ai D | cut -d' ' -f1)"
[ "$x" == 1999-12-31 ] \
  && log 'Correct author date' || fail "Wrong author date ($x)"
x="$(git log -1 --pretty=%ci B | cut -d' ' -f1)"
[ "$x" != 1999-12-31 ] \
  && log 'Correct committer date' || fail "Wrong committer date ($x)"
x="$(git log -1 --pretty=%ci D | cut -d' ' -f1)"
[ "$x" == 1999-12-31 ] \
  && log 'Correct committer date' || fail "Wrong committer date ($x)"

log 'Test option: date (epoch with offset)'
"$GCS" --date='946673999 -0300' B
x="$(git log -1 --pretty=%ct B)"
[ "$x" != 946673999 ] \
  && log 'Correct committer date' || fail "Wrong committer date ($x)"
x="$(git log -1 --pretty=%ct D)"
[ "$x" == 946673999 ] \
  && log 'Correct committer date' || fail "Wrong committer date ($x)"
x="$(git log -1 --pretty=%ai D)"
[ "$x" == '1999-12-31 17:59:59 -0300' ] \
  && log 'Correct author date' || fail "Wrong author date ($x)"

log 'Test option: date-like-commit'
git checkout -b F A
"$GCS" --date-like-commit=A B
x="$(git log -1 --pretty=%at)"
[ "$x" == 978343810 ] \
  && log 'Correct author date' || fail "Wrong author date ($x)"
x="$(git log -1 --pretty=%ct)"
[ "$x" == 978343810 ] \
  && log 'Correct committer date' || fail "Wrong committer date ($x)"

log 'Test option: date-like-file'
file="$(mktemp -t git-copy.XXXXXXXX)"
touch --date='2006-12-04 09:30:00' "$file"
git checkout -b E A
"$GCS" --date-like-file="$file" B
x="$(git log -1 --pretty=%ai E | cut -d' ' -f1)"
[ "$x" == 2006-12-04 ] \
  && log 'Correct author date' || fail "Wrong author date ($x)"
rm -f "$file"

log 'Test option: date-from-author'
"$GCS" B
x="$(git log -1 --pretty=%ai E | cut -d' ' -f1)"
[ "$x" == 2003-03-03 ] \
  && log 'Correct author date' || fail "Wrong author date ($x)"
x="$(git log -1 --pretty=%ci E | cut -d' ' -f1)"
[ "$x" != 1999-12-31 ] \
  && log 'Correct committer date' || fail "Wrong committer date ($x)"
"$GCS" --date-from-author B
x="$(git log -1 --pretty=%ai E | cut -d' ' -f1)"
[ "$x" == 2003-03-03 ] \
  && log 'Correct author date' || fail "Wrong author date ($x)"
x="$(git log -1 --pretty=%ci E | cut -d' ' -f1)"
[ "$x" == 2003-03-03 ] \
  && log 'Correct committer date' || fail "Wrong committer date ($x)"

log 'Test option: date-from-committer'
"$GCS" --date-from-committer B
x="$(git log -1 --pretty=%ai E | cut -d' ' -f1)"
[ "$x" == 2003-04-04 ] \
  && log 'Correct author date' || fail "Wrong author date ($x)"
x="$(git log -1 --pretty=%ci E | cut -d' ' -f1)"
[ "$x" == 2003-04-04 ] \
  && log 'Correct committer date' || fail "Wrong committer date ($x)"

log 'Test args: single'
git checkout C
x="$(git log -1 --pretty=%h)"
"$GCS" B
y="$(git log -1 --pretty=%h C^)"
[ "$x" == "$y" ] \
  && log 'Created single-commit copy' || fail 'Single-copy failed'

clean_up
echo 'All tests passed'
exit
