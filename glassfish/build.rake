namespace = File.basename(File.expand_path("..", __FILE__))

version = (ENV['version'].nil? or ENV['version'].empty?) ? '3.1.2.2' : ENV['version']
name = 'glassfish'
download_url = "http://download.java.net/#{name}/#{version}/release/#{name}-#{version}.zip"

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
      system("unzip #{name}-#{version}.zip")
      FileUtils.mv "#{name}3", "#{name}" if version =~ /^3\./
      system("echo 'jre-1.8=${jre-1.7}' >> #{name}/glassfish/config/osgi.properties")
      FileUtils.rm_r "#{name}/glassfish/domains/domain1"
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("fpm -s dir -t deb -n #{name} -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -a all \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'Glassfish is an open source Java EE server' \
	      -d java-runtime-headless --prefix /opt #{name}" )
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r(Dir.glob("#{name}*"), :force => true)
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
