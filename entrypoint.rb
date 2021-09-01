#!/usr/bin/env ruby

require 'set'

def warn(file, message)
    if (ENV['GITHUB_ACTIONS'] == 'true') then
        `::warning file=#{file},line=1,col=1::#{message}`
    else
        `W: #{"Warning on file #{file}:\n#{message}".gsub(/\R/, "\nW: ")}`
    end
end

puts `ls test`

command = ARGV[0] || 'rubber --unsafe --inplace -d --synctex -s'
verbose = ARGV[1].to_s.downcase != "false"
success_list = ARGV[2] || 'success-list'
magic_comment_matcher = /^\s*%.*!\s*[Tt][Ee][xX]\s*root\s*=\s*(.*\.[Tt][Ee][xX]).*$/
tex_files = targets = Dir["**/*.tex"]
    .map { |it| File.expand_path(it) }
    .reject { |it| it =~ /^\/(usr|etc|bin)\/.*$/ }
puts "Found these tex files: #{tex_files}" if verbose
tex_roots = tex_files.filter_map do |file|
    File.read(file)
        .match(magic_comment_matcher, 1)
        .then { |match| [file, match] }
end
tex_ancillary, tex_roots = tex_roots.partition { | _, match | match }
tex_ancillary.each do |file, match|
    File.file?(match) && tex_roots << match ||
        warn(file, "#{file} declares its root to be #{match}, but such file does not exist.")
end
tex_roots = tex_roots.map(&:first).to_set
puts "Detected the following LaTeX roots: #{tex_roots}"
successes = Set[]
previous_successes = nil
failures = Set[]
until successes == tex_roots || successes == previous_successes do
    previous_successes = successes
    failures = Set[]
    (tex_roots - successes).each do |root|
        match = root.match(/^(.*)\/(.*\.[Tt][Ee][xX])$/)
        directory = match[1]
        target = match[2]
        Dir.chdir(directory)
        install_command = "texliveonfly #{target}"
        puts "Installing required packages via #{install_command}"
        output = `#{install_command}`
        puts(output) if verbose
        puts "Compiling #{target} with '#{command} #{target}'"
        output = `#{command} #{target}`
        puts(output) if verbose
        $?.success? && successes << root || failures << [root, output]
    end
end 
File.open(success_list, "w+") do |file|
    successes.each do |success|
        file.puts success
    end
end
failures.each do |file, output|
    warn(file, "failed to compile, output:\n#{output}")
end
exit failures.size
