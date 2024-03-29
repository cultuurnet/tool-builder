namespace = File.basename(File.expand_path("..", __FILE__))

phar = (ENV['version'].nil? or ENV['version'].empty?) ? "phpunit.phar" : "phpunit-#{ENV['version']}.phar"

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget https://phar.phpunit.de/#{phar} -O phpunit")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("pkg")
      FileUtils.mv("phpunit", "pkg")
      FileUtils.chmod(0755, "pkg/phpunit")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_artifact => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = `php pkg/phpunit --version`.split(' ')[1].chomp
      system("fpm -s dir -t deb -a all -C pkg -v #{version} -n phpunit \
        -d 'php7.4-cli' --prefix /usr/bin \
        --license 'Apache-2.0' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq VZW' \
        --description 'PHP Unit testing framework.' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("pkg", :force => true)
      FileUtils.rm(Dir.glob("phpunit_*_all.deb"))
      FileUtils.rm("phpunit", :force => true)
    }
  end
end
