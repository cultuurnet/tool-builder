namespace = File.basename(File.expand_path("..", __FILE__))
version = (ENV['version'].nil? or ENV['version'].empty?) ? '1.26.0' : ENV['version']

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
  task :build_artifact => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.1.0 mono_logger")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.5.2 redis-namespace")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 3.2.2 redis")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 0.1.11 vegas")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v #{version} resque")
      version = `dpkg --info rubygem-resque*.deb | grep "^ Version:"`.split(' ')[1]
      iteration = `date '+%Y%m%d%H%M%S'`.chomp

      system("mkdir -p var/log/resque-web")
      system("mkdir -p var/lib/resque-web")
      #system("rm -f rubygem-resque*.deb")
      system("fpm -s dir -t deb -n resque-web -a all -v #{version} \
        -m 'Infra publiq <infra@publiq.be>' -d 'rubygem-resque' \
        --url 'https://www.publiq.be' --vendor 'publiq VZW' \
        --deb-systemd systemd/resque-web.service --deb-default default/resque-web \
        --deb-user www-data --deb-group www-data --iteration #{iteration} \
        -x build.rake -x systemd -x default -x '*.deb' --prefix / .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
