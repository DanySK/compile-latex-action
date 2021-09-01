#/bin/sh
set -e
docker build -t test .
docker run -v "$(pwd)/test":/test:rw test 
