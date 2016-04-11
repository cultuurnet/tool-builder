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
      system("fpm -s gem -t deb mailcatcher")
      version = `dpkg --info rubygem-mailcatcher*.deb | grep "^ Version:"`.split(' ')[1]

      system("fpm -s dir -t deb -n mailcatcher -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -d 'rubygem-mailcatcher' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --deb-upstart upstart/mailcatcher --deb-default default/mailcatcher \
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
