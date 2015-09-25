# encoding: utf-8

# how to use:
# bundle install
# bundle exec guard

require 'guard/guard'

module ::Guard
  class Thesis < ::Guard::Guard
    def run_all
    end

    def run_on_changes(paths)
      puts "Changes in:\n"
      puts paths
      `rubber --pdf report.tex`
      `make clean`
    end
  end
end

guard :thesis do
  watch(/^.*\.(tex|bib)$/)
end
