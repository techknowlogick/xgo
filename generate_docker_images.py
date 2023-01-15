import requests
import os
import hashlib
import re
from jsonpath_ng import jsonpath, parse

def generate_image(image):
  version = image["version"].replace("go1","go-1")
  wildcard = version
  if version.count('.') > 1:
    wildcard = re.sub("\.\d+$", ".x", version)
  else:
    version = version + ".0"
    wildcard = wildcard + ".x"
  try:
    os.mkdir("docker/"+version)
  except:
    print("version folder already exists")
  try:
    os.mkdir("docker/"+wildcard)
  except:
    print("wildcard folder already exists")
  # now that folders have been created, the Dockerfile needs to be created
  f = open("docker/"+version+"/Dockerfile", "w")
  f.write("## GENERATED. DO NOT EDIT DIRECTLY.\n")
  f.write("FROM toolchain\n\n")
  f.write("ENV GO_VERSION "+version.replace("go-","").replace(".","")+"\n\n")
  f.write("RUN \\\n")
  f.write("  export ROOT_DIST=https://dl.google.com/go/"+image["filename"]+" && \\\n")
  f.write("  export ROOT_DIST_SHA="+image["sha256"]+" && \\\n")
  f.write("  \\\n")
  f.write("$BOOTSTRAP_PURE\n")
  f.close()
  # now wildcard version
  f = open("docker/"+wildcard+"/Dockerfile", "w")
  f.write("## GENERATED. DO NOT EDIT DIRECTLY.\n")
  f.write("FROM "+version+"\n")
  f.close()

r = requests.get('https://golang.org/dl/?mode=json')

if r.status_code != requests.codes.ok:
  print("error fetching golang versions")
  exit(1)

try:
  golangJson = r.json()
except:
  print("failed to parse json")
  exit(1)

if len(golangJson) != 2:
  # the script below assumes only two stable versions
  print("unexpected number of golang versions returned")
  exit(1)

fileExpr = parse('$.[*].files')
files = [match.value for match in fileExpr.find(golangJson)]
versionExpr = parse('$.[*].version')
versions = [match.value for match in versionExpr.find(golangJson)]
docker_images = []
for file in files:
  x = [f for f in file if (f['os'] == "linux" and f['arch'] == "amd64" ) ][0]
  docker_images.append(x)

for docker_image in docker_images:
  generate_image(docker_image)

# write latest image
if docker_images[0]["version"].count('.') > 1:
  wildcard = re.sub("\.\d+$", ".x", docker_images[0]["version"])
else:
  wildcard = docker_images[0]["version"] + ".x"
try:
    os.mkdir("docker/go-latest")
except:
  print("go-latest folder already exists")

f = open("docker/go-latest/Dockerfile", "w")
f.write("## GENERATED. DO NOT EDIT DIRECTLY.\n")
f.write("FROM techknowlogick/xgo:"+wildcard.replace("go1", "go-1")+"\n")
f.close()

hs = hashlib.sha256(r.text.encode('utf-8')).hexdigest()
f = open(".golang_hash", "w")
f.write(hs)
f.close()
f = open(".golang_version", "w")
f.write(",".join(versions))
f.close()
