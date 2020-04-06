namespace = File.basename(File.expand_path("..", __FILE__))

version = (ENV['version'].nil? or ENV['version'].empty?) ? '3.8.8' : ENV['version']
name = 'liquibase'
download_url = "https://github.com/#{name}/#{name}/releases/download/v#{version}/#{name}-#{version}.tar.gz"

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget #{download_url} -O #{name}-#{version}.tar.gz")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("liquibase")
      system("tar -C liquibase -xzvf #{name}-#{version}.tar.gz")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("fpm -s dir -t deb -n #{name} -v #{version} \
        -m 'Infra publiq <infra@publiq.be>' -a all --license 'Apache-2.0' \
        --url 'https://www.publiq.be' --vendor 'publiq vzw' \
        --description 'Liquibase helps track, version, and deploy database schema changes.' \
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
