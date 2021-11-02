package_namespace = File.basename(File.expand_path("..", __FILE__)).to_sym

require 'nokogiri'

name = 'jenkins-swarm-client'
download_location = "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client"
version = (ENV['version'].nil? or ENV['version'].empty?) ? 'latest' : ENV['version']

namespace package_namespace do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      if version == 'latest'
        system("wget #{download_location}/maven-metadata.xml")
        metadata = Nokogiri::XML(File.open('maven-metadata.xml'))
        actual_version = metadata.xpath('//metadata//versioning//latest').text
      else
        actual_version = version
      end

      system("wget #{download_location}/#{actual_version}/swarm-client-#{actual_version}.jar")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("pkg/usr/share/#{name}")
      FileUtils.mkdir_p("pkg/usr/bin")
      FileUtils.mkdir_p("pkg/etc/#{name}")

      system("cp swarm-client-*.jar pkg/usr/share/#{name}/swarm-client.jar")
      system("install -m 0755 #{name} pkg/usr/bin/#{name}")
      system("touch pkg/etc/#{name}/node-labels.conf")
      system("touch pkg/etc/#{name}/password")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = `ls swarm-client-*.jar`[/swarm\-client\-(.+)\.jar/, 1]
      iteration = `date '+%Y%m%d%H%M%S'`.chomp
      system("fpm -s dir -t deb -a all -C pkg -n #{name} -v #{version} \
        --iteration #{iteration} --prefix / \
        --after-install postinst --before-remove prerm \
        -x upstart --deb-upstart upstart/jenkins-swarm-client \
        -x systemd --deb-systemd systemd/jenkins-swarm-client.service \
        --license 'Apache-2.0' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq vzw' \
        --description 'Jenkins Swarm client' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r('pkg', :force => true)
      FileUtils.rm_r('maven-metadata.xml', :force => true)
      FileUtils.rm(Dir.glob("#{name}_*_all.deb"), :force => true)
      FileUtils.rm(Dir.glob("swarm-client-*.jar"), :force => true)
    }
  end
end
