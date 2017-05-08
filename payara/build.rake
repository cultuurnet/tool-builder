namespace = File.basename(File.expand_path("..", __FILE__))

version = (ENV['version'].nil? or ENV['version'].empty?) ? '4.1.1.171.1' : ENV['version']
short_version = version.split('.')[0..1].join
name = 'payara'
download_url = "http://search.maven.org/remotecontent?filepath=fish/#{name}/distributions/#{name}/#{version}/#{name}-#{version}.zip"

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget #{download_url} -O #{name}-#{version}.zip")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("unzip #{name}-#{version}.zip")
      FileUtils.mv "#{name}#{short_version}", "#{name}"
      FileUtils.rm_r(Dir.glob("#{name}/glassfish/domains/*"), :force => true)
      FileUtils.chmod 0777, "#{name}/glassfish/domains"
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("fpm -s dir -t deb -n #{name} -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -a all \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'Payara Server is a drop in replacement for GlassFish Server Open Source Edition' \
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
