#! /bin/bash

dart fix --apply

cd switchboardd
dart fix --apply

cd ..


git add --all .
git commit -m "[dart] autofixes"
