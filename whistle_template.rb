require 'base64'
require File.join(File.expand_path(File.dirname(template), File.join(root,'..')), 'template_framework')

init_template_framework template, root
load_options

# Delete unnecessary files
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"

# Set up git repository
# must do before running piston or braid
git :init

# Set up gitignore and commit base state
file '.gitignore', load_pattern('.gitignore')

file "lib/tasks/git.rake", load_pattern("lib/tasks/git.rake", "git")

commit_state "base application"

# plugins
install_plugins

rake("git:submodules:init")
commit_state "Added plugins"

# gems
# if @gem_dependencies == "bundler"
#   if yes?("Install bundler with sudo?")
#     run 'sudo gem install bundler'
#   else
#     run 'gem install bundler'
#   end
# end

install_gems

# if @gem_dependencies == "bundler"
#   file ".gitignore", load_pattern('gitignore_with_bundler')
#   commit_state "Bundled gems"
# 
#   file "config/preinitializer.rb", load_pattern("config/preinitializer_with_bundler.rb")
#   commit_state "Added preinitializer with bundler"
# else
#   commit_state "Added gems"
# end
commit_state "Added gems"

# environment updates
in_root do
  run 'cp config/environments/production.rb config/environments/staging.rb'
end
environment 'config.middleware.use "Rack::Bug"', :env => 'development'
environment 'config.middleware.use "Rack::Bug"', :env => 'staging'

environment 'config.action_mailer.delivery_method = :smtp', :env => 'production'
environment 'config.action_mailer.delivery_method = :smtp', :env => 'staging'

bullet_initializer = load_snippet('bullet_initializer')
environment bullet_initializer, :env => 'development'

commit_state "Set up staging environment and hooked up Rack::Bug"

# make sure HAML files get searched if we go that route
file '.ackrc', load_pattern('.ackrc')

# jrails setup
if @javascript_library == "jquery"
  rake("jrails:js:scrub")
  rake("jrails:js:install")
end

# "bluetrip"
inside('public') do
  run('mkdir img')
end
inside('public/img') do
  run('mkdir icons')
end
file_from_repo "mikecrittenden", "bluetrip-css-framework", "master", "css/ie.css", "public/stylesheets/ie.css"
file_from_repo "mikecrittenden", "bluetrip-css-framework", "master", "css/print.css", "public/stylesheets/print.css"
file_from_repo "mikecrittenden", "bluetrip-css-framework", "master", "css/screen.css", "public/stylesheets/screen.css"
file_from_repo "mikecrittenden", "bluetrip-css-framework", "master", "css/style.css", "public/stylesheets/style.css"
file_from_repo "mikecrittenden", "bluetrip-css-framework", "master", "img/grid.png", "public/img/grid.png"
%w(cross doc email external feed im information key pdf tick visited xls).each do |icon|
  file_from_repo "mikecrittenden", "bluetrip-css-framework", "master", "img/icons/#{icon}.png", "public/img/icons/#{icon}.png"
end

if template_engine == "haml"
  run "haml --rails ."
end

file 'app/views/layouts/_flashes.html.haml', load_pattern('app/views/layouts/_flashes.html.haml', 'default')

javascript_include_tags = load_snippet('javascript_include_tags', @javascript_library)

file 'app/views/layouts/application.html.haml', load_pattern('app/views/layouts/application.html.haml', 'default', binding)

# rakefile for use with inaction_mailer
rakefile 'mail.rake', load_pattern('lib/tasks/mail.rake')
# rakefile for use with annotate
rakefile 'annotate.rake', load_pattern('lib/tasks/annotate.rake')

#file 'public/stylesheets/application.css', load_pattern('public/stylesheets/application.css', 'default', binding)

# design template files - file list was generated
file 'public/stylesheets/custom.css', load_pattern('public/stylesheets/custom.css')
#images
file 'public/images/banner.jpg',      load_pattern('public/images/banner.jpg')
file 'public/images/bg.jpg',          load_pattern('public/images/bg.jpg')
file 'public/images/body_bg.jpg',     load_pattern('public/images/body_bg.jpg')
file 'public/images/footer.jpg',      load_pattern('public/images/footer.jpg')
file 'public/images/h_line.jpg',      load_pattern('public/images/h_line.jpg')
file 'public/images/home_icon.jpg',   load_pattern('public/images/home_icon.jpg')
file 'public/images/learn.jpg',       load_pattern('public/images/learn.jpg')
file 'public/images/learn_over.jpg',  load_pattern('public/images/learn_over.jpg')
file 'public/images/left_foot.jpg',   load_pattern('public/images/left_foot.jpg')
file 'public/images/light.jpg',       load_pattern('public/images/light.jpg')
file 'public/images/navi_left.jpg',   load_pattern('public/images/navi_left.jpg')
file 'public/images/navi_right.jpg',  load_pattern('public/images/navi_right.jpg')
file 'public/images/page_bg.jpg',     load_pattern('public/images/page_bg.jpg')
file 'public/images/right_foot.jpg',  load_pattern('public/images/right_foot.jpg')
file 'public/images/rpt.jpg',         load_pattern('public/images/rpt.jpg')
file 'public/images/studio.jpg',      load_pattern('public/images/studio.jpg')
file 'public/images/tabright1.gif',   load_pattern('public/images/tabright1.gif')
file 'public/images/tableft1.gif',    load_pattern('public/images/tableft1.gif')

generate(:formtastic)

file 'app/controllers/application_controller.rb', load_pattern('app/controllers/application_controller.rb', controller_type)
file 'app/helpers/application_helper.rb', load_pattern('app/helpers/application_helper.rb')
file 'app/helpers/layout_helper.rb', load_pattern('app/helpers/layout_helper.rb')

# initializers
initializer 'requires.rb', load_pattern('config/initializers/requires.rb')

initializer 'admin_data.rb', load_pattern('config/initializers/admin_data.rb', 'default', binding)

base64_user_name = Base64.encode64(smtp_username) unless smtp_username.blank? 
base64_password = Base64.encode64(smtp_password) unless smtp_username.blank? 

initializer 'mail.rb', load_pattern('config/initializers/mail.rb', 'default', binding)
initializer 'date_time_formats.rb', load_pattern('config/initializers/date_time_formats.rb')
initializer 'query_trace.rb', load_pattern('config/initializers/query_trace.rb')
initializer 'backtrace_silencers.rb', load_pattern('config/initializers/backtrace_silencers.rb')
initializer 'haml_with_html5.rb', load_pattern('config/initializers/haml_with_html5.rb')

commit_state "application files and initializers"

# deployment
capify!

file 'config/deploy.rb', load_pattern('config/deploy.rb', 'default', binding)
file 'config/deploy/production.rb', load_pattern('config/deploy/production.rb', 'default', binding)
file 'config/deploy/staging.rb', load_pattern('config/deploy/staging.rb', 'default', binding)
# rake tasks to ease Heroku deployment
file 'lib/tasks/gems.rake', load_pattern('lib/tasks/gems.rake')

commit_state "deployment files"

# error handling
file 'config/exceptional.yml', load_pattern('config/exceptional.yml', 'default', binding)

# performance monitoring
file 'config/newrelic.yml', load_pattern('config/newrelic.yml', 'default', binding)

# database
file 'config/database.yml', load_pattern("config/database.#{database}.yml", 'default', binding)
file 'db/populate/01_sample_seed.rb', load_pattern('db/populate/01_sample_seed.rb')

account_create_flash = "Account registered!"

# locale
file 'config/locales/en.yml', load_pattern('config/locales/en.yml', 'default', binding)

commit_state "configuration files"

# testing
file 'test/exemplars/sample_exemplar.rb', load_pattern('test/exemplars/sample_exemplar.rb')
mock_require = ""
mock_include = ""
#mocking with mocha
mock_require = "require 'mocha'"
file 'test/test_helper.rb', load_pattern('test/test_helper.rb', 'default', binding)
file 'config/preinitializer.rb', load_pattern('config/preinitializer.rb')

extra_notifier_test = ""

file 'test/unit/notifier_test.rb', load_pattern('test/unit/notifier_test.rb', 'default', binding)

welcome_callback = ""
extra_user_tests = ""
welcome_callback = "should_callback :send_welcome_email, :after_create"

file 'test/unit/user_test.rb', load_pattern('test/unit/user_test.rb', 'default', binding)

file 'test/shoulda_macros/authlogic.rb', load_pattern('test/shoulda_macros/authlogic.rb')
file 'test/shoulda_macros/filter.rb', load_pattern('test/shoulda_macros/filter.rb')
file 'test/shoulda_macros/helpers.rb', load_pattern('test/shoulda_macros/helpers.rb')

file 'test/exemplars/user_exemplar.rb', load_pattern('test/exemplars/user_exemplar.rb')

file 'test/unit/user_session_test.rb', load_pattern('test/unit/user_session_test.rb', 'default', binding)

file 'test/unit/helpers/application_helper_test.rb', load_pattern('test/unit/helpers/application_helper_test.rb', 'default', binding)


file 'test/functional/accounts_controller_test.rb', load_pattern('test/functional/accounts_controller_test.rb', 'default', binding)

generate_user_block = ""
generate_user_block = load_snippet('generate_user_block')

file 'test/functional/application_controller_test.rb', load_pattern('test/functional/application_controller_test.rb', 'default', binding)

file 'test/functional/users_controller_test.rb', load_pattern('test/functional/users_controller_test.rb', 'default', binding)

file 'test/functional/user_sessions_controller_test.rb', load_pattern('test/functional/user_sessions_controller_test.rb', 'default', binding)

upgrade_test = ''
if ie6_blocking == 'light'
  upgrade_test = load_snippet('ie6_blocking_light_upgrade_test')
end

file 'test/functional/pages_controller_test.rb', load_pattern('test/functional/pages_controller_test.rb', 'default', binding)
file 'test/functional/password_resets_controller_test.rb', load_pattern('test/functional/password_resets_controller_test.rb', 'default', binding)

new_user_contained_text = 'I18n.t("flash.accounts.create.notice")'

new_user_extra_fields = ""
new_user_extra_fields = load_snippet('new_user_extra_fields')

file 'test/integration/new_user_can_register_test.rb', load_pattern('test/integration/new_user_can_register_test.rb', 'default', binding)
file 'test/integration/user_can_login_test.rb', load_pattern('test/integration/user_can_login_test.rb', 'default', binding)
file 'test/integration/user_can_logout_test.rb', load_pattern('test/integration/user_can_logout_test.rb', 'default', binding)

commit_state "basic tests"

# authlogic setup

account_create_block = ""
account_create_block = load_snippet('account_create_block')

file 'app/controllers/accounts_controller.rb', load_pattern('app/controllers/accounts_controller.rb', controller_type, binding)

file 'app/controllers/password_resets_controller.rb', load_pattern('app/controllers/password_resets_controller.rb', controller_type)
file 'app/controllers/user_sessions_controller.rb', load_pattern('app/controllers/user_sessions_controller.rb', controller_type)

user_create_block = ""
user_create_block = load_snippet('user_create_block')

file 'app/controllers/users_controller.rb' , load_pattern('app/controllers/users_controller.rb', controller_type, binding)

activation_instructions_block = ""
file 'app/models/notifier.rb', load_pattern('app/models/notifier.rb', 'default', binding)

file 'app/models/user.rb', load_pattern('app/models/user.rb')

file 'app/models/user_session.rb', load_pattern('app/models/user_session.rb')

file 'app/views/notifier/password_reset_instructions.html.haml', load_pattern('app/views/notifier/password_reset_instructions.html.haml')
file 'app/views/notifier/welcome_email.html.haml', load_pattern('app/views/notifier/welcome_email.html.haml')
file 'app/views/password_resets/edit.html.haml', load_pattern('app/views/password_resets/edit.html.haml')
file 'app/views/password_resets/new.html.haml', load_pattern('app/views/password_resets/new.html.haml')

file 'app/views/user_sessions/new.html.haml', load_pattern('app/views/user_sessions/new.html.haml')
#else: file 'app/views/user_sessions/new.html.haml', load_pattern('app/views/user_sessions/new.html.haml')

file 'app/views/users/index.html.haml', load_pattern('app/views/users/index.html.haml')

password_input_block = ""
password_input_block = load_snippet('password_input_block')

file 'app/views/users/_form.html.haml', load_pattern('app/views/users/_form.html.haml', 'default', binding)

file 'app/views/users/edit.html.haml', load_pattern('app/views/users/edit.html.haml')

file 'app/views/users/new.html.haml', load_pattern('app/views/users/new.html.haml')

file 'app/views/users/show.html.haml', load_pattern('app/views/users/show.html.haml')

# file 'db/migrate/01_create_users.rb', load_pattern('db/migrate/01_create_users.rb', 'require_activation')
file 'db/migrate/01_create_users.rb', load_pattern('db/migrate/01_create_users.rb')

file 'db/migrate/02_create_sessions.rb', load_pattern('db/migrate/02_create_sessions.rb')

commit_state "basic Authlogic setup"

# static pages
ie6_method = ""
if ie6_blocking == "light"
  ie6_method = load_snippet("ie6_method")
end

file 'app/controllers/pages_controller.rb', load_pattern('app/controllers/pages_controller.rb', controller_type, binding)

ie6_warning = ""
if ie6_blocking == "light"
  ie6_warning = load_snippet('ie6_blocking_light_warning')
elsif ie6_blocking == "ie6nomore"
  ie6_warning =  load_snippet('ie6_blocking_ie6nomore_warning')
end

top_menu_class = ""
left_menu_class = ""
main_with_left_menu_class = ""
# "bluetrip"
top_menu_class = load_snippet("top_menu_class", "bluetrip")
left_menu_class = load_snippet("left_menu_class", "bluetrip")
main_with_left_menu_class = load_snippet("main_with_left_menu_class", "bluetrip")

file 'app/views/pages/home.html.haml', load_pattern('app/views/pages/home.html.haml', 'default', binding)
file 'app/views/pages/whistle.html.haml', load_pattern('app/views/pages/whistle.html.haml', 'default', binding)
file 'app/views/pages/css_test.html.haml', load_pattern('app/views/pages/css_test.html.haml')
if ie6_blocking == 'light'
  file 'app/views/pages/upgrade.html.haml', load_pattern('app/views/pages/upgrade.html.haml', 'default', binding)
end

file 'doc/README_FOR_APP', load_pattern('doc/README_FOR_APP', 'default', binding)

commit_state "static pages"

activation_routes = ""

# simple default routing
file 'config/routes.rb', load_pattern('config/routes.rb', 'default', binding)

commit_state "routing"

# databases
rake('db:create')
rake('db:migrate')
rake('parallel:prepare[4]')
commit_state "databases set up"

# annotations
run 'annotate -i -p after'
run 'annotate -r'

commit_state "annotated models and routes"

# rakefile for metric_fu
rakefile 'metric_fu.rake', load_pattern('lib/tasks/metric_fu.rake')

commit_state "metric_fu setup"

# vendor rails if desired
# takes the edge of whatever branch is specified in the config file
# defaults to 2-3-stable at the moment
# if rails_strategy == "vendored" || rails_strategy == "symlinked"
#   if rails_strategy == "vendored"
#     install_rails :branch => rails_branch
#     commit_state "vendored rails"
#   elsif rails_strategy == "symlinked"
#     inside('vendor') do
#       run("ln -s #{link_rails_root} rails")
#     end
#   end
#   update_app
#   remove_prototype if @javascript_library != "prototype"
#   commit_state "updated rails files from vendored copy"
# end

# set up branches
git_branch_setup

# post-creation work
execute_post_creation_hooks

# Success!
puts "SUCCESS!"
puts '  Set up new app at http://getexceptional.com/apps'
puts '  Put the right API key in config/exceptional.yml'
puts '  Put the right API key in config/new_relic.yml'
puts '  Create public/favicon.ico'
puts '  Put the production database password in config/database.yml'
puts '  Put mail server information in mail.rb'
puts '  Put real IP address and git repo URL in deployment files'
puts '  Add app to gitosis config'
puts "  git remote add origin git@#{capistrano_repo_host}:#{current_app_name}.git"
puts '  git push origin master:refs/heads/master'
