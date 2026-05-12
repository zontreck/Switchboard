#! /bin/bash

dart fix --apply
git add --all .
git commit -m "[dart] autofixes"
