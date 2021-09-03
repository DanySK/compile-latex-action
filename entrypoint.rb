#!/usr/bin/env ruby

require 'set'

def warn(file, message)
    if (ENV['GITHUB_ACTIONS'] == 'true') then
        `::warning file=#{file},line=1,col=1::#{message}`
    else
        puts "W: #{"Warning on file #{file}:\n#{message}".gsub(/\R/, "\nW: ")}"
    end
end

command = ARGV[0] || 'rubber --unsafe --inplace -d --synctex -s -W all'
verbose = ARGV[1].to_s.downcase == "true"
output_variable = ARGV[2] || 'LATEX_SUCCESSES'

magic_comment_matcher = /^\s*%.*!\s*[Tt][Ee][xX]\s*root\s*=\s*(.*\.[Tt][Ee][xX]).*$/
initial_directory = File.expand_path('.') + '/'
puts "Working from #{initial_directory}"
tex_files = Dir[
    "#{initial_directory}*.tex",
    "#{initial_directory}**/*.tex",
    "#{initial_directory}*.TEX",
    "#{initial_directory}**/*.TEX",
    "#{initial_directory}*.TeX",
    "#{initial_directory}**/*.TeX",
]
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
tex_roots = tex_roots.map(&:first)
puts "Detected the following LaTeX roots: #{tex_roots}"
tex_roots = tex_roots.to_set
successes = Set[]
previous_successes = nil
failures = Set[]
until successes == tex_roots || successes == previous_successes do
    previous_successes = successes
    failures = Set[]
    (tex_roots - successes).each do |root|
        match = root.match(/^(.*)\/(.*\.[Tt][Ee][xX])$/)
        install_command = "texliveonfly #{root}"
        puts "Installing required packages via #{root}"
        output = `#{install_command} 2>&1`
        puts(output) if verbose
        puts "Compiling #{root} with '#{command} #{root}'"
        output << `#{command} #{root} 2>&1`
        puts(output) if verbose
        Dir.chdir(initial_directory)
        if $?.success? then
            successes << root
        else
            failures << [root, output]
        end
    end
end 
success_list = successes.map{ |it| it.sub(initial_directory, '') }.join("\n")

heredoc_delimiter = 'EOF'
export = "#{output_variable}<<#{heredoc_delimiter}\n#{success_list}\n#{heredoc_delimiter}"
puts 'Generated variable output:'
puts export

github_environment = ENV['GITHUB_ENV']
if !success_list.empty? && github_environment then
    puts 'Detected actual GitHub Actions environment, running the export'
    File.open(github_environment, 'a') do |env|
        env.puts(export)
    end
    puts File.open(github_environment).read
end

failures.each do |file, output|
    warn(file, "failed to compile, output:\n#{output}")
end
exit failures.size
