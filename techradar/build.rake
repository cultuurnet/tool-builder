namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("git clone git@github.com:thoughtworks/build-your-own-radar.git")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd "#{task.name.split(':')[0]}/build-your-own-radar" do
      system("npm install")
      system("npm run build")
    end
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = Time.now.strftime("%Y%m%d%H%M%S")
      system("fpm -s dir -t deb -n techradar -a all -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --prefix /var/www/techradar -C build-your-own-radar/dist ."
      )
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("build-your-own-radar", :force => true)
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
