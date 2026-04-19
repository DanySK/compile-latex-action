#!/usr/bin/env ruby
require 'json'

class TestRepository
    attr_reader :name, :env_vars

    def initialize(name, env_vars = [])
        @name = name
        @env_vars = env_vars
    end
end

puts `docker build -t test .`

test_repositories = [
    TestRepository.new('Course-Simulation-Basics'),
    TestRepository.new('Curriculum-Vitae', ['SERPAPI_KEY']),
    TestRepository.new('Template-Elsevier-Article'),
    TestRepository.new('Template-Elsevier-CAS-DC'),
    TestRepository.new('Template-IEEE-Computer-Society-Magazines'),
    TestRepository.new('Template-IEEE-Conference-Proceedings'),
    TestRepository.new('Template-LaTeX-achemso'),
    TestRepository.new('Template-LaTeX-acmart'),
    TestRepository.new('Template-LaTeX-CI'),
    TestRepository.new('Template-LaTeX-ERC'),
    TestRepository.new('Template-LaTeX-LMCS'),
    TestRepository.new('Template-LaTeX-LNCS'),
    TestRepository.new('Template-LaTeX-MDPI'),
    TestRepository.new('Template-PhD-Tesi-Giovanni-Ciatto'),
]

missing_env_vars = test_repositories.each_with_object({}) do |repo, missing|
    unavailable = repo.env_vars.select { |env_var| ENV[env_var].to_s.strip.empty? }
    missing[repo.name] = unavailable unless unavailable.empty?
end

if missing_env_vars.key?('Curriculum-Vitae')
    warn <<~WARNING
        WARNING: SERPAPI_KEY is undefined or empty.
        WARNING: Curriculum-Vitae will still be tested, but it will use its fallback mechanism instead of the SerpAPI-backed path.
        WARNING: Define SERPAPI_KEY before running ./test.rb to exercise the SerpAPI-backed behavior locally.
    WARNING
end

`sudo rm -rf test`
`mkdir test`
threads = test_repositories.map { | repo |
    Thread.new { 
        `git clone --recurse-submodules https://github.com/DanySK/#{repo.name}.git test/test-#{repo.name}`
    }
}
for thread in threads do
    thread.join
end
docker_command = [
    'docker', 'run', '--rm',
    '--workdir=/github/workspace',
    '-v', "#{Dir.pwd}/test:/github/workspace:rw",
]
forwarded_env_vars = test_repositories.flat_map(&:env_vars).uniq
forwarded_env_vars.each do |env_var|
    docker_command += ['-e', env_var] unless ENV[env_var].to_s.strip.empty?
end
docker_command << 'test'

puts docker_command.join(' ')
system(*docker_command)
exit($?.exitstatus)
