#!/usr/bin/env ruby

require 'set'

def annotate(level, marker, file, message)
  title = marker == 'E' ? "Compilation failed for #{file}" : "Warning for #{file}"
  puts "::#{level} file=#{file},title=#{title}::#{message}"
  descriptor = marker == 'E' ? "Error in file #{file}:\n#{message}" : "Warning on file #{file}:\n#{message}"
  puts "#{marker}: #{descriptor.gsub(/\R/, "\n#{marker}: ")}"
end

# Emit a GitHub error annotation and a prefixed message
def error(file, message)
  annotate('error', 'E', file, message)
end

# Emit a GitHub warning annotation and a prefixed message
def warn(file, message)
  annotate('warning', 'W', file, message)
end

command = ARGV[0] || 'rubber --unsafe --inplace -d --synctex -s -W all'
verbose = ARGV[1].to_s.downcase == 'true'
output_variable = ARGV[2] || 'LATEX_SUCCESSES'

initial_directory = File.expand_path('.') + '/'
puts "Working from #{initial_directory}"

# Gather all .tex files
tex_files = Dir[
  "#{initial_directory}*.tex",
  "#{initial_directory}**/*.tex",
  "#{initial_directory}*.TEX",
  "#{initial_directory}**/*.TEX",
  "#{initial_directory}*.TeX",
  "#{initial_directory}**/*.TeX"
]
puts "Found these tex files: #{tex_files}" if verbose

# Exclude any .tex file that does not contain a \documentclass declaration
filtered = []
tex_files.each do |file|
  content = File.read(file, encoding: 'UTF-8').lines.reject { |it| it.match?(/^\s*%/) }
  if content.any? {|it| it =~ /\\documentclass/ }
    filtered << file
  else
    warn(file, "Excluded from compilation because it lacks a \\documentclass declaration.")
  end
end
tex_files = filtered.to_set
puts "Including #{tex_files.to_a} for compilation" if verbose

# Detect magic-root comments
magic_comment_matcher = /^\s*%\s*!\s*[Tt][Ee][xX]\s*root\s*=\s*(.*\.[Tt][Ee][xX]).*$/
roots_and_ancillary = tex_files.map do |file|
  content = File.read(file, encoding: 'UTF-8')
  match = content[magic_comment_matcher, 1]
  [file, match]
end

# Separate ancillary (with magic roots) vs true roots
tex_ancillary, tex_roots = roots_and_ancillary.partition { |_, match| match }
puts "These files have been detected as ancillary: #{tex_ancillary.map(&:first)}"

# Resolve ancillary to actual roots
tex_roots = tex_roots.map(&:first)
tex_ancillary.each do |file, match|
  full_path = File.join(File.dirname(file), match || '')
  if File.file?(full_path)
    tex_roots << full_path
  else
    warn(file, "#{file} declares its root as #{match}, but that file does not exist.")
  end
end

tex_roots = tex_roots.to_set
puts "Detected the following LaTeX roots: #{tex_roots}" if verbose

# Compile loop
successes = Set.new
previous_successes = nil
failures = Set.new
until successes == tex_roots || successes == previous_successes do
  previous_successes = successes.dup
  failures = Set.new
  (tex_roots - successes).each do |root|
    Dir.chdir(File.dirname(root))
    puts "Compiling #{root} with: \"#{command} '#{root}'\""
    output = `#{command} '#{root}' 2>&1`
    puts output if verbose
    Dir.chdir(initial_directory)

    if $?.success?
      successes << root
    else
      failures << [root, output]
    end
  end
end

# Prepare outputs
success_list = successes.map { |f| f.sub(initial_directory, '') }
pdf_list = success_list.map { |file| file.sub(/\.[Tt][Ee][Xx]?$/, '.pdf') }

github_output = ENV['GITHUB_OUTPUT']
if github_output
  File.open(github_output, 'a') do |f|
    f.puts("successfully-compiled=#{success_list.join(',')}")
    f.puts("compiled-files=#{pdf_list.join(',')}")
  end
else
  error('', "GITHUB_OUTPUT env variable not set; using deprecated set-output syntax.")
  puts "::set-output name=successfully-compiled::#{success_list.join(',')}"
  puts "::set-output name=compiled-files::#{pdf_list.join(',')}"
end

# Also expose list via environment variable if configured
heredoc_delimiter = 'EOF'
export = "#{output_variable}<<#{heredoc_delimiter}\n#{success_list.join("\n")}\n#{heredoc_delimiter}"
puts 'Generated variable output:'
puts export

github_env = ENV['GITHUB_ENV']
if !success_list.empty? && github_env
  puts 'Detected GitHub Actions environment; exporting list.'
  File.open(github_env, 'a') { |env| env.puts(export) }
end

# Report failures as errors
failures.each do |file, output|
  error(file, "failed to compile, output:\n#{output}")
end

exit failures.size
