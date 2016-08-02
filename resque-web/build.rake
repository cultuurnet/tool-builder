namespace = File.basename(File.expand_path("..", __FILE__))

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
      system("fpm -s gem -t deb resque")
      version = `dpkg --info rubygem-resque*.deb | grep "^ Version:"`.split(' ')[1]

      system("mkdir -p var/{log,run}/resque-web")
      system("fpm -s dir -t deb -n resque-web -a all -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -d 'rubygem-resque' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --deb-upstart upstart/resque-web --deb-default default/resque-web \
        --deb-user www-data --deb-group www-data \
        -x build.rake -x upstart -x default -x '*.deb' --prefix / .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm("*.deb", :force => true)
    }
  end
end
