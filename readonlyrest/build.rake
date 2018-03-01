namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget https://s3-eu-west-1.amazonaws.com/udb3-vagrant/readonlyrest-1.16.16_es5.2.2.zip -O readonlyrest-1.16.16.zip")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("elasticsearch-readonlyrest")
      FileUtils.mv("readonlyrest-1.16.16.zip", "elasticsearch-readonlyrest")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = '1.16.16'
      system("fpm -s dir -t deb -a all -v #{version} -n elasticsearch-readonlyrest --prefix /opt \
        --license 'Apache-2.0' -m 'Infra CultuurNet <infra@cultuurnet.be>' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'Readonlyrest, simpler security & access control for Elasticsearch and Kibana' elasticsearch-readonlyrest")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("elasticsearch-readonlyrest", :force => true)
      FileUtils.rm(Dir.glob("elasticsearch-readonlyrest_*_all.deb"))
      FileUtils.rm(Dir.glob("readonlyrest-*.zip"))
    }
  end
end
