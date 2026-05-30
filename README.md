<!-- mode: markdown; indent-tabs-mode: nil; tab-width: 4 -->

rs-rename
==========
A file/folder renamer.

usage
-----

`rsrename <root> '<regex>' '<replacement>' [-n]`

where:
- `-n`: don't rename, just report what would be done.
    - handy to check that regex is picking up on expected items
    - handy to check that the renames are as expected.

- `<root>`: is the folder root to start from.
    - it's expected that shell will expand envvars and ~ (note: sometimes it doesn't).

- `<regex>`: is the regex to search for.
    - protect spaces etc by placing regex in single-quotes
    - regex is as per regex crate.
    - use capture strings for repl using ( and ).

- `<replace>`: is the string to replace each occurrence with.
    - use $n as capture string substitution of group n (e.g. $1)
    - use ${n} as capture string substitution of group n (e.g. ${1})


Examples
--------
`rsrename /path/to/folder '(.*)thing$' '${1}-fish'`

Would replace all files/folders with names ending in thing to those now ending in '-fish'.

note: (..) is a capture group.


Why?
----
1. The perl one is rubbish.
2. I dislike perl.
3. Why install all of perl for a simple util?
4. Why not.
