# encoding utf-8

require "ruby-progressbar"

PROJECT = ARGV[0]

abort "ERROR: Need 1.9.3 version. Now #{RUBY_VERSION}" if RUBY_VERSION != "1.9.3"
abort "ERROR: Need project name" if PROJECT == nil

Dir.mkdir PROJECT 

Dir.mkdir "#{PROJECT}/models"
Dir.mkdir "#{PROJECT}/views"
Dir.mkdir "#{PROJECT}/controllers"
Dir.mkdir "#{PROJECT}/db"
Dir.mkdir "#{PROJECT}/helpers"
Dir.mkdir "#{PROJECT}/public"

PROJECT__APP_RB = "
# encoding utf-8

require \"rubygems\"
require \"sinatra\"
require \"data_mapper\"
require \"slim\"

require \"./models/main\"
require \"./controllers/site\"
require \"./controllers/admin\"
require \"./helpers/main\"
"

PROJECT__MODELS__MAIN_RB = "
# encoding utf-8

DataMapper.setup :default, \"sqlite:\#{Dir.pwd}/db/main.db\"

class Foo
  include DataMapper::Resource

  property :id, Serial
end

DataMapper.finalize
DataMapper.auto_upgrade!
"

PROJECT__VIEWS__SITE_INDEX_SLIM = "
b Hello World
"

PROJECT__VIEWS__SITE_LAYOUT_SLIM = "
doctype html
html lang=\"en\"
  head
    title #{PROJECT}
    meta charset=\"utf-8\"
  body
  == yield
"

PROJECT__VIEWS__ADMIN_INDEX_SLIM = "
b Hello World
"

PROJECT__VIEWS__ADMIN_LAYOUT_SLIM = "
doctype html
html lang=\"en\"
  head
    title #{PROJECT}
    meta charset=\"utf-8\"
  body
  == yield
"

PROJECT__CONROLLERS__SITE_RB = "
# encoding utf-8

get \"/\" do
  # Do miracles here

  slim :site_index, :layout => :site_layout, :locals => {}
end
"

PROJECT__CONROLLERS__ADMIN_RB = "
# encoding utf-8

get \"/admin\" do
  protected!

  # Do miracles here

  slim :admin_index, :layout => :admin_layout, :locals => {}
end
"

PROJECT__HELPERS__MAIN_RB = "
# encoding utf-8

helpers do
  def protected!
    unless authorized?
      response[\"WWW-Authenticate\"] = %(Basic realm=\"Restricted Area\")
      throw(:halt, [401, \"Not authorized\\n\"])
    end
  end
  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [\"admin\", \"admin\"]
  end
end
"

ProgressBar.create :total => 9, :output => STDERR

IO.write "#{PROJECT}/app.rb", PROJECT__APP_RB
ProgressBar.increment
IO.write "#{PROJECT}/models/main.rb", PROJECT__MODELS__MAIN_RB
ProgressBar.increment
IO.write "#{PROJECT}/views/site_index.slim", PROJECT__VIEWS__SITE_INDEX_SLIM
ProgressBar.increment
IO.write "#{PROJECT}/views/site_layout.slim", PROJECT__VIEWS__SITE_LAYOUT_SLIM
ProgressBar.increment
IO.write "#{PROJECT}/views/admin_index.slim", PROJECT__VIEWS__ADMIN_INDEX_SLIM
ProgressBar.increment
IO.write "#{PROJECT}/views/admin_layout.slim", PROJECT__VIEWS__ADMIN_LAYOUT_SLIM
ProgressBar.increment
IO.write "#{PROJECT}/controllers/site.rb", PROJECT__CONROLLERS__SITE_RB
ProgressBar.increment
IO.write "#{PROJECT}/controllers/admin.rb", PROJECT__CONROLLERS__ADMIN_RB
ProgressBar.increment
IO.write "#{PROJECT}/helpers/main.rb", PROJECT__HELPERS__MAIN_RB
ProgressBar.increment
