namespace = File.basename(File.expand_path("..", __FILE__))
version = (ENV['version'].nil? or ENV['version'].empty?) ? '0.6.5' : ENV['version']

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
      system("fpm -s gem -t deb -v #{version} mailcatcher")

      system("fpm -s dir -t deb -n mailcatcher -a all -v '#{version}' \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -d 'rubygem-mailcatcher' \
        -d 'ruby' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --deb-upstart upstart/mailcatcher --deb-default default/mailcatcher \
        -x build.rake -x upstart -x default -x '*.deb' --prefix / .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
