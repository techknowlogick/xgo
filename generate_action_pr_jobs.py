import os
import json
import sys

from git import Repo

# set cwd as repo
repo = Repo(os.getcwd())
commit = repo.head.commit

# get list of changed files
changed_files = repo.git.diff_tree('--no-commit-id', '--name-only', '-r', commit)

# check if base needs to be built
base_changed = False
for x in changed_files:
    if x.startswith("docker/base"):
        base_changed = True
        break

# get golang versions that need to be built
golang_versions = []
f = open(".golang_version", "r")
golang_versions = f.read().split(",")
f.close()

output = {}
output['fail-fast'] = False
output['matrix'] = {}
output['matrix']['include'] = [{"name":"golang versions","golang_version_1":golang_versions[0],"golang_version_2":golang_versions[1]}]

print(json.dumps(output))
