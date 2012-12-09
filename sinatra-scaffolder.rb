# encoding utf-8
# http://code.jquery.com/jquery.min.js
# http://twitter.github.com/bootstrap/assets/bootstrap.zip

abort "ERROR: Need 1.9.3 version. Now #{RUBY_VERSION}" if RUBY_VERSION != "1.9.3"

begin
  require "rubygems"
  require "ruby-progressbar"
  require "trollop"
rescue LoadError, Exception => exception
  abort "ERROR: #{exception.message}"
end

options = Trollop::options do
  version "2"
  banner "Sinatra-Scaffolder"
  opt :project, "Project name", :type => :string, :required => :true
  opt :libraries, "Include libraries. Now support: Bootstrap, jQuery", :type => :strings
  opt :admin, "Use Admin and DataBase" # type => boolean, :default => false
  opt :template_language, "Template language. Now support: slim", :type => :string, :default => "slim"
end

dirs = 
{
  :models => "models",
  :views => "views",
  :controllers => "controllers",
  :helpers => "helpers",
  :db => "db",
  :public => "public"
}

files =
{
  :app => 
  {
    :app => "app.rb"
  },

  :models => 
  {
    :main => "#{dirs[:models]}/main.rb"
  },

  :views => 
  {
    :site_index => "#{dirs[:views]}/site_index.#{options[:template_language].downcase}",
    :site_layout => "#{dirs[:views]}/site_layout.#{options[:template_language].downcase}",
    :admin_index => "#{dirs[:views]}/admin_index.#{options[:template_language].downcase}",
    :admin_layout => "#{dirs[:views]}/admin_layout.#{options[:template_language].downcase}"
  },

  :controllers => 
  {
    :site => "#{dirs[:controllers]}/site.rb",
    :admin => "#{dirs[:controllers]}/admin.rb"
  },

  :helpers => 
  {
    :admin => "#{dirs[:helpers]}/admin.rb"
  }
}

sources = 
{
  :app =>
  {
    :app => "# encoding utf-8\n\nrequire \"rubygems\"\nrequire \"sinatra\"\nrequire \"data_mapper\"\nrequire \"slim\"\nrequire \"require_all\"\n\nrequire_all \"./\""
  },
  
  :models =>
  {
    :main => "# encoding utf-8\n\nDataMapper.setup :default, \"sqlite:\#{Dir.pwd}/db/main.db\""
  },
  
  :views =>
  {
    :site_index => "b Hello World",
    :site_layout => "doctype html\nhtml\n\thead\n\t\ttitle #{options[:project]}\n\t\tmeta charset=\"utf-8\"\n\tbody\n\t== yield",
    :admin_index => "b Hello World",
    :admin_layout => "doctype html\nhtml lang=\"en\"\n\thead\n\t\ttitle #{options[:project]}\n\t\t\meta charset=\"utf-8\"\n\tbody\n\t== yield"
  },
  
  :controllers =>
  {
    :site => "# encoding utf-8\n\nget \"/\" do\n\t# Do miracles here\n\n\tslim :site_index, :layout => :site_layout, :locals => {}\nend",
    :admin => "# encoding utf-8\n\nget \"/admin\" do\n\tprotected!\n\n\t# Do miracles here\n\n\tslim :admin_index, :layout => :admin_layout, :locals => {}\nend"
  },
  
  :helpers =>
  {
    :admin => "# encoding utf-8\n\nhelpers do\n\tdef protected!\n\t\tunless authorized?\n\t\t\tresponse[\"WWW-Authenticate\"] = %(Basic realm=\"Restricted Area\")\n\t\t\tthrow(:halt, [401, \"Not authorized\\n\"])\n\t\tend\n\tend\n\tdef authorized?\n\t\t@auth ||= Rack::Auth::Basic::Request.new(request.env)\n\t\t@auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [\"admin\", \"admin\"]\n\tend\nend"
  }
}

Dir.mkdir options[:project].downcase
Dir.chdir options[:project].downcase

dirs.each_key do |key|
  Dir.mkdir dirs[key]
end

files.each_key do |key_a|
  files[key_a].each_key do |key_b|
    IO.write files[key_a][key_b], sources[key_a][key_b]
  end
end