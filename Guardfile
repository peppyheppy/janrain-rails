group 'backend' do
  guard 'bundler' do
    watch('Gemfile')
    watch('Gemfile.lock')
  end

  # guard 'rspec', rvm: '1.9.2', all_on_start: false, cli: "--color -d --format nested --color --profile", :bundle => false do
  #   watch(%r{^spec/.+_spec\.rb$})
  #   watch(%r{spec/(.*)_spec.rb})
  #   watch(%r{lib/(.*)\.rb})                            { |m| "spec/lib/#{m[1]}_spec.rb" }
  #   watch('spec/spec_helper.rb')                       { "spec" }
  # end
end

guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/lib/janrain/capture/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

# guard 'rspec', :version => 2 do
#   watch(%r{^spec/.+_spec\.rb$})
#   watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
#   watch('spec/spec_helper.rb')  { "spec" }
# 
#   # Rails example
#   watch(%r{^spec/.+_spec\.rb$})
#   watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
#   watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
#   watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
#   watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
#   watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
#   watch('spec/spec_helper.rb')                        { "spec" }
#   watch('config/routes.rb')                           { "spec/routing" }
#   watch('app/controllers/application_controller.rb')  { "spec/controllers" }
#   # Capybara request specs
#   watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/#{m[1]}_spec.rb" }
# end

