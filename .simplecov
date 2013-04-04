SimpleCov.start 'rails' do
  coverage_dir 'test/output/coverage'

  merge_timeout 3600
  minimum_coverage 75
  maximum_coverage_drop 3

  add_filter "test"
  add_filter "vendor"

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Views", "app/views"
  add_group "Libs", "lib/"
  add_group "Presenters", "app/presenters"
  add_group "Uploaders", "app/uploaders"
  add_group "Mailers", "app/mailers"

  formatter Coveralls::SimpleCov::Formatter
end
