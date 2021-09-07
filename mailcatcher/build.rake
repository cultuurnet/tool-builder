namespace = File.basename(File.expand_path("..", __FILE__))
version = (ENV['version'].nil? or ENV['version'].empty?) ? '0.6.5' : ENV['version']
iteration = Time.now.strftime("%Y%m%d%H%M%S")

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
      system("sudo apt-get install build-essential")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.0.9.1 eventmachine")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 2.7.1 mail")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.0.2 mini_mime")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.6.4 rack")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.4.7 sinatra")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.5.3 rack-protection")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 2.0.2 tilt")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 0.2.4 skinny")
      system("sudo apt-get install libsqlite3-dev")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.3.11 sqlite3")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.5.1 thin")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.2.3 daemons")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v #{version} mailcatcher")

      system("fpm -s dir -t deb -n mailcatcher -a all -v '#{version}' --iteration '#{iteration}' \
        -m 'Infra publiq <infra@publiq.be>' -d rubygem-mailcatcher -d ruby \
        --url 'https://www.publiq.be' --vendor 'publiq VZW' \
        --deb-systemd systemd/mailcatcher.service --deb-default default/mailcatcher \
        -x build.rake -x upstart -x systemd -x default -x '*.deb' --prefix / .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
