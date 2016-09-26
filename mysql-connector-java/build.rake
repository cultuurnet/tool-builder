namespace = File.basename(File.expand_path("..", __FILE__))

version = (ENV['version'].nil? or ENV['version'].empty?) ? '5.1.39' : ENV['version']
name = 'mysql-connector-java'
download_url = "https://dev.mysql.com/get/Downloads/Connector-J/#{name}-#{version}.tar.gz"

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
      system("tar xzf #{name}-#{version}.tar.gz")
      FileUtils.mkdir name
      FileUtils.cp "#{name}-#{version}/#{name}-#{version}-bin.jar", "#{name}/#{name}.jar"
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("fpm -s dir -t deb -n #{name} -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -a all \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'MySQL Connector/J is the official JDBC driver for MySQL' \
	      --prefix /opt #{name} ")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("#{name}*", :force => true)
      FileUtils.rm("*.deb", :force => true)
    }
  end
end
