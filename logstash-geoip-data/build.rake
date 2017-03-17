namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("curl -O http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("gunzip *.gz")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      require 'time'

      version = DateTime.now.strftime('%Y%m%d%H%M%S')
      system("fpm -s dir -t deb -a all -v #{version} -n logstash-geoip-data --prefix /etc/logstash/geoip \
        --license 'Apache-2.0' -m 'Infra CultuurNet <infra@cultuurnet.be>' -x build.rake \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'MaxMind GeoIP database' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm(Dir.glob("logstash-geoip-data_*_all.deb"))
      FileUtils.rm("GeoLiteCity.dat", :force => true)
      FileUtils.rm("GeoLiteCity.dat.gz", :force => true)
    }
  end
end
