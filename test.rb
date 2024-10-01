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

`sudo rm -rf test`
`mkdir test`
threads = my_latex.map { | repo |
    Thread.new { 
        `git clone --recurse-submodules https://github.com/DanySK/#{repo}.git test/test-#{repo}`
    }
}
for thread in threads do
    thread.join
end
puts `docker run --rm --workdir="/github/workspace" -v "$(pwd)/test":/github/workspace:rw test`
exit $?.exitstatus
