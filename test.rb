#!/usr/bin/env ruby
require 'json'
puts `docker build -t test .`

repos = [
    'https://github.com/DanySK/Template-PhD-Tesi-Giovanni-Ciatto.git',
]
index = 0
for repo in repos do
    `git clone #{repo} test/test-#{index += 1}`
end
`docker run -v "$(pwd)/test":/test:rw test 'rubber --unsafe --inplace -d --synctex -s' 'false'`
exit $?.exitstatus
