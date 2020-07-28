namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version_string = (ENV['version'].nil? or ENV['version'].empty?) ? "" : "--version=#{ENV['version']}"
      system("curl -sS https://getcomposer.org/installer | php -- --filename=composer #{version_string}")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("pkg")
      FileUtils.mv("composer","pkg")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = `pkg/composer --no-ansi -V`.split[2]
      system("fpm -s dir -t deb -a all -C pkg -v #{version} -n composer -d 'php5-cli | php5.6-cli | php7.1-cli | php7.4-cli' --prefix /usr/bin \
        --license 'Apache-2.0' -m 'Infra CultuurNet <infra@cultuurnet.be>' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'Composer is a dependency manager tracking local dependencies of your projects and libraries' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("pkg", :force => true)
      FileUtils.rm(Dir.glob("composer_*_all.deb"))
      FileUtils.rm("composer", :force => true)
    }
  end
end
