namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("git clone https://github.com/nagios-plugins-rabbitmq/nagios-plugins-rabbitmq.git")
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
      require 'json'

      metadata = JSON.load(File.read('nagios-plugins-rabbitmq/META.json'))
      version = metadata['version'][/[\d\.]+/]

      %w(Config::Tiny Math::Calc::Units Module::Implementation Module::Runtime Params::Validate Try::Tiny).each do | perl_package |
        system("fpm -s cpan -t deb #{perl_package}")
      end

      system("fpm -s cpan -t deb --no-depends -d 'perl-config-tiny' -d 'perl-math-calc-units' \
        -d 'perl-module-implementation' -d 'perl-module-runtime' -d 'perl-params-validate' \
        -d 'perl-try-tiny' Monitoring::Plugin")

      system("fpm -s dir -t deb -n nagios-plugins-rabbitmq -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -d 'perl-monitoring-plugin' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
	      --prefix /usr/lib/nagios/plugins -C nagios-plugins-rabbitmq/scripts .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("nagios-plugins-rabbitmq", :force => true)
      FileUtils.rm("*.deb", :force => true)
    }
  end
end
