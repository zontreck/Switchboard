@echo off

title Switchboard Autofix
color 1a

call dart fix --apply

git add --all .
git commit -m "[dart] autofixes"