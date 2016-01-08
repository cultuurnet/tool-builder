namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget http://files.drush.org/drush.phar -O drush")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("pkg")
      FileUtils.mv("drush","pkg")
      FileUtils.chmod("0755","pkg/drush")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = `php pkg/drush version --format=string`.chomp
      system("fpm -s dir -t deb -a all -C pkg -v #{version} -n drush -d php5-cli --prefix /usr/bin \
        --license 'Apache-2.0' -m 'Infra CultuurNet <infra@cultuurnet.be>' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'Drush is a command line shell and Unix scripting interface for Drupal.' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("pkg", :force => true)
      FileUtils.rm(Dir.glob("drush_*_all.deb"))
      FileUtils.rm("drush", :force => true)
    }
  end
end
