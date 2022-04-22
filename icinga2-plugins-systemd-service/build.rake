namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("git clone https://github.com/patrikskrivanek/icinga2-check_systemd_service.git")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r('icinga2-check_systemd_service/README.md', :force => true)
      FileUtils.chmod(0755, 'icinga2-check_systemd_service/check_systemd_service')
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = `icinga2-check_systemd_service/check_systemd_service -V`[/^v(.*)$/, 1]
      system("fpm -s dir -t deb -n icinga2-plugins-systemd-service -a all \
        -v #{version} -x '*/.git' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq VZW' \
        --description 'Icinga2 exchange plugin for monitoring systemd services' \
	      --prefix /usr/lib/nagios/plugins -C icinga2-check_systemd_service .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("icinga2-check_systemd_service", :force => true)
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
