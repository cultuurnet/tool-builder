namespace = File.basename(File.expand_path("..", __FILE__))

version = (ENV['version'].nil? or ENV['version'].empty?) ? 'latest' : ENV['version']

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget http://www.phing.info/get/phing-#{version}.phar -O phing")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("pkg")
      FileUtils.mv("phing", "pkg")
      FileUtils.chmod(0755, "pkg/phing")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_artifact => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = `php pkg/phing -v`.split(' ')[1]
      system("fpm -s dir -t deb -a all -C pkg -v #{version} -n phing -d 'php7.1-cli | php7.4-cli' --prefix /usr/bin \
        --license 'Apache-2.0' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq VZW' \
        --description 'PHing Is Not GNU make; it is a PHP project build system or build tool based on Apache Ant.' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("pkg", :force => true)
      FileUtils.rm(Dir.glob("phing_*_all.deb"))
      FileUtils.rm("phing", :force => true)
    }
  end
end
