namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget https://getcomposer.org/composer-1.phar -O composer1")
      system("wget https://getcomposer.org/composer-2.phar -O composer2")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.chmod(0755, "composer1", :verbose => true)
      FileUtils.chmod(0755, "composer2", :verbose => true)
      FileUtils.mkdir_p("pkg/composer1")
      FileUtils.mkdir_p("pkg/composer2")
      FileUtils.mv("composer1","pkg/composer1")
      FileUtils.mv("composer2","pkg/composer2")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version_composer1 = `pkg/composer1/composer1 --no-ansi -V`.split[2]
      version_composer2 = `pkg/composer2/composer2 --no-ansi -V`.split[2]
      system("fpm -s dir -t deb -a all -C pkg/composer1 -v #{version_composer1} \
        -n composer1 -d 'php5-cli | php5.6-cli | php7.1-cli | php7.4-cli' \
        --after-install postinst/composer1 --before-remove prerm/composer1 \
        --license 'Apache-2.0' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq VZW' --prefix /usr/bin \
        --description 'Composer is a dependency manager tracking local dependencies of your projects and libraries' \
        --provides composer .")
      system("fpm -s dir -t deb -a all -C pkg/composer2 -v #{version_composer2} \
        -n composer2 -d 'php5-cli | php5.6-cli | php7.1-cli | php7.4-cli' \
        --after-install postinst/composer2 --before-remove prerm/composer2 \
        --license 'Apache-2.0' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq VZW' --prefix /usr/bin \
        --description 'Composer is a dependency manager tracking local dependencies of your projects and libraries' \
        --provides composer .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("pkg", :force => true)
      FileUtils.rm(Dir.glob("composer_*_all.deb"), :force => true)
      FileUtils.rm(Dir.glob("composer*"), :force => true)
    }
  end
end
