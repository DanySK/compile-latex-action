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
success_list = ARGV[1] || 'success-list'
verbose = ARGV[1].to_s.downcase != "false"
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
        Dir.chdir(root[/^(.*\/).*\.[Tt][Ee][xX]$/, 1])
        install_command = "texliveonfly #{root}"
        puts "Installing required packages via #{install_command}"
        output = `#{install_command}`
        puts(output) if verbose
        puts "Compiling #{root} with '#{command} #{root}'"
        output = `#{command} #{root}`
        puts(output) if verbose
        $?.success? && successes << root || failures << [root, output]
    end
end 
File.open(success_list, "w+") do |f|
    f.puts(successes)
end
failures.each do |file, output|
    warn(file, "failed to compile, output:\n#{output}")
end
exit failures.size
