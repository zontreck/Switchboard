@echo off

title Switchboard Autofix
color 1a

call dart fix --apply

cd switchboardd
call dart fix --apply

cd ..

git add --all .
git commit -m "[dart] autofixes"


color