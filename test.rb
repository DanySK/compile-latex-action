#!/usr/bin/env ruby
require 'json'
puts `docker build -t test .`

repos = [
    'https://github.com/DanySK/Course-Simulation-Basics.git',
    'https://github.com/DanySK/Curriculum-Vitae.git',
    'https://github.com/DanySK/Template-PhD-Tesi-Giovanni-Ciatto.git',
    'https://github.com/DanySK/Template-Elsevier-Article.git',
]
index = 0
`sudo rm -rf test`
`mkdir test`
for repo in repos do
    `git clone #{repo} test/test-#{index += 1}`
end
puts `docker run --rm --workdir="/github/workspace" -v "$(pwd)/test":/github/workspace:rw test`
exit $?.exitstatus
