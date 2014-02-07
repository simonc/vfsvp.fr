require 'rubygems'
require 'bundler/setup'
require 'stringex'

deploy_branch  = 'gh-pages'

## -- Misc Configs -- ##

public_dir      = 'public'    # compiled site directory
source_dir      = 'source'    # source file directory
blog_index_dir  = 'source'    # directory for your blog's index page (if you put your index in source/blog/index.html, set this to 'source/blog')
deploy_dir      = '_deploy'   # deploy directory (for Github pages deployment)
posts_dir       = '_posts'    # directory for blog files
new_post_ext    = 'md'        # default new post file extension when using the new_post task
new_page_ext    = 'md'        # default new page file extension when using the new_page task
server_port     = '4000'      # port for preview server eg. localhost:4000

#######################
# Working with Jekyll #
#######################

desc 'Generate jekyll site'
task :generate do
  puts '-----> Generating Site with Jekyll'
  # system "compass compile --css-dir #{source_dir}/stylesheets"
  system 'jekyll'
end

desc 'Watch the site and regenerate when it changes'
task :watch do
  puts 'Starting to watch source with Jekyll and Sass.'
  jekyllPid = Process.spawn({ 'OCTOPRESS_ENV' => 'preview' }, 'jekyll --auto')
  sassPid = Process.spawn("sass -r 'bootstrap-sass' --watch sass:#{source_dir}/stylesheets")

  trap('INT') {
    [jekyllPid, sassPid].each { |pid| Process.kill(9, pid) rescue Errno::ESRCH }
    exit 0
  }

  [jekyllPid, sassPid].each { |pid| Process.wait(pid) }
end

desc 'preview the site in a web browser'
task :preview do
  puts "Starting to watch source with Jekyll and Sass. Starting Rack on port #{server_port}"
  jekyllPid = Process.spawn({ 'OCTOPRESS_ENV' => 'preview' }, 'jekyll --auto')
  sassPid = Process.spawn("sass -r 'bootstrap-sass' --watch sass:#{source_dir}/stylesheets")
  rackupPid = Process.spawn("rackup --port #{server_port}")

  trap('INT') {
    [jekyllPid, sassPid, rackupPid].each { |pid| Process.kill(9, pid) rescue Errno::ESRCH }
    exit 0
  }

  [jekyllPid, sassPid, rackupPid].each { |pid| Process.wait(pid) }
end

desc "Begin a new post in #{source_dir}/#{posts_dir}"
task :new_post, :title do |t, args|
  title = args.title ? args.title : get_stdin('Enter a title for your post: ')
  mkdir_p "#{source_dir}/#{posts_dir}"
  filename = "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort('rake aborted!') if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts '---'
    post.puts 'layout: post'
    post.puts %Q(title: "#{title.gsub(/&/,'&amp;')}")
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts 'comments: true'
    post.puts 'categories: '
    post.puts '---'
  end
end

desc "Create a new page in #{source_dir}/(filename)/index.#{new_page_ext}"
task :new_page, :filename do |t, args|
  args.with_defaults(filename: 'new-page')
  page_dir = [source_dir]
  if args.filename.downcase =~ /(^.+\/)?(.+)/
    filename, dot, extension = $2.rpartition('.').reject(&:empty?)         # Get filename and extension
    title = filename
    page_dir.concat($1.downcase.sub(/^\//, '').split('/')) unless $1.nil?  # Add path to page_dir Array
    if extension.nil?
      page_dir << filename
      filename = 'index'
    end
    extension ||= new_page_ext
    page_dir = page_dir.map(&:to_url).join('/') # Sanitize path
    filename = filename.downcase.to_url

    mkdir_p page_dir
    file = "#{page_dir}/#{filename}.#{extension}"
    if File.exist?(file)
      abort('rake aborted!') if ask("#{file} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
    end
    puts "Creating new page: #{file}"
    open(file, 'w') do |page|
      page.puts '---'
      page.puts 'layout: page'
      page.puts %Q(title: "#{title}")
      page.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
      page.puts 'comments: true'
      page.puts 'sharing: true'
      page.puts 'footer: true'
      page.puts '---'
    end
  else
    puts "Syntax error: #{args.filename} contains unsupported characters"
  end
end

desc 'Clean out caches: .pygments-cache, .gist-cache, .sass-cache'
task :clean do
  rm_rf ['.pygments-cache/**', '.gist-cache/**', '.sass-cache/**', 'source/stylesheets/screen.css']
end

##############
# Deploying  #
##############

desc 'Default deploy task'
task :deploy do
  if File.exists?('.preview-mode')
    puts '-----> Found posts in preview mode, regenerating files...'
    File.delete('.preview-mode')
    Rake::Task[:generate].execute
  end

  Rake::Task[:copydot].invoke(source_dir, public_dir)
  Rake::Task["#{deploy_default}"].execute
end

desc 'Generate website and deploy'
task :gen_deploy => [:integrate, :generate, :deploy] do
end

desc 'copy dot files for deployment'
task :copydot, :source, :dest do |t, args|
  FileList["#{args.source}/**/.*"].exclude("**/.", "**/..", "**/.DS_Store", "**/._*").each do |file|
    cp_r file, file.gsub(/#{args.source}/, "#{args.dest}") unless File.directory?(file)
  end
end

desc 'deploy public directory to github pages'
multitask :push do
  puts '-----> Deploying branch to Github Pages'
  puts '-----> Pulling any updates from Github Pages'
  cd "#{deploy_dir}" do
    system 'git pull'
  end
  (Dir["#{deploy_dir}/*"]).each { |f| rm_rf f }
  Rake::Task[:copydot].invoke(public_dir, deploy_dir)
  puts "## Copying #{public_dir} to #{deploy_dir}"
  cp_r "#{public_dir}/.", deploy_dir
  cd "#{deploy_dir}" do
    system 'git add -A'
    puts "-----> Commiting: Site updated at #{Time.now.utc}"
    message = "Site updated at #{Time.now.utc}"
    system %Q(git commit -m "#{message}")
    puts "-----> Pushing generated #{deploy_dir} website"
    system "git push origin #{deploy_branch}"
    puts "-----> Github Pages deploy complete"
  end
end

def ok_failed(condition)
  puts condition ? 'OK' : 'FAILED'
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def ask(message, valid_options)
  if valid_options
    get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    get_stdin(message)
  end
end

desc 'list tasks'
task :list do
  puts "Tasks: #{(Rake::Task.tasks - [Rake::Task[:list]]).join(', ')}"
  puts '(type rake -T for more detail)'
end
