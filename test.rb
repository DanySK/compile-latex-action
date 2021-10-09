#!/usr/bin/env ruby
require 'json'
puts `docker build -t test .`

my_latex = [
    'Course-Simulation-Basics',
    'Curriculum-Vitae',
    'Template-ACM-Article',
    'Template-Elsevier-Article',
    'Template-Elsevier-CAS-DC',
    'Template-IEEE-Computer-Society-Magazines',
    'Template-IEEE-Conference-Proceedings',
    'Template-LaTeX-achemso',
    'Template-LaTeX-CI',
    'Template-LaTeX-ERC',
    'Template-LaTeX-LMCS',
    'Template-LaTeX-LNCS',
    'Template-LaTeX-MDPI',
    'Template-PhD-Tesi-Giovanni-Ciatto',
]

repos = my_latex.map { |it| "https://github.com/DanySK/#{it}.git" }
index = 0
`sudo rm -rf test`
`mkdir test`
for repo in repos do
    `git clone #{repo} test/test-#{index += 1}`
end
puts `docker run --rm --workdir="/github/workspace" -v "$(pwd)/test":/github/workspace:rw test`
exit $?.exitstatus
