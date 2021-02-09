namespace = File.basename(File.expand_path("..", __FILE__))
version = (ENV['version'].nil? or ENV['version'].empty?) ? '2.0.1' : ENV['version']

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("sudo apt-get install build-essential")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 2.15.10 cri")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 2.0.3 pl-puppetdb-ruby")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 0.6.0 multi_xml")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 3.2020.1104 mime-types-data")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 3.3.1 mime-types")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 0.18.1 httparty")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v #{version} puppetdb_cli")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
