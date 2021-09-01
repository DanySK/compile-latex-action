#!/usr/bin/env ruby
require 'json'
puts `docker build -t test .`

repos = [
    'https://github.com/DanySK/Template-PhD-Tesi-Giovanni-Ciatto.git',
]
index = 0
`rm -rf test`
`mkdir test`
for repo in repos do
    `git clone #{repo} test/test-#{index += 1}`
end
puts `docker run -v "$(pwd)/test":/test:rw test`
exit $?.exitstatus
