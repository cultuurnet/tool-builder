namespace = File.basename(File.expand_path("..", __FILE__))

version = (ENV['version'].nil? or ENV['version'].empty?) ? '8u151' : ENV['version']
name = 'oracle-jdk8-archive'
download_url = "https://java-archives.s3-eu-west-1.amazonaws.com/jdk-#{version}-linux-x64.tar.gz"

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget #{download_url}")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir 'oracle-jdk8-installer'
      FileUtils.mv "jdk-#{version}-linux-x64.tar.gz", "oracle-jdk8-installer"
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("fpm -s dir -t deb -n #{name} -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -a all \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'Oracle Java(TM) Development Kit (JDK) 8 archive' \
	      --prefix /var/cache oracle-jdk8-installer")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r(Dir.glob("oracle-jdk8-installer"), :force => true)
      FileUtils.rm_r(Dir.glob("jdk-*"), :force => true)
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
