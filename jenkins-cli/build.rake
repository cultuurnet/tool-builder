namespace = File.basename(File.expand_path("..", __FILE__))

version = (ENV['version'].nil? or ENV['version'].empty?) ? 'latest' : ENV['version']
name = 'jenkins-cli'
download_url = "http://mirrors.jenkins.io/war-stable/#{version}/jenkins.war"

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget #{download_url}")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("pkg/usr/share/#{name}")
      FileUtils.mkdir_p("pkg/usr/bin")
      system("jar xf jenkins.war $(jar tf jenkins.war | grep 'WEB-INF/lib/cli-')")
      system("mv WEB-INF/lib/cli-*.jar pkg/usr/share/#{name}")

      version = `ls pkg/usr/share/#{name}`[/cli\-(.+)\.jar/, 1]
      File.open("pkg/usr/bin/#{name}", 'w') { |file| file.write("#!/bin/bash\n\njava -jar /usr/share/#{name}/cli-#{version}.jar -s http://localhost:8080/ $@\n") }
      FileUtils.chmod(0755, "pkg/usr/bin/#{name}")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = `ls pkg/usr/share/#{name}`[/cli\-(.+)\.jar/, 1]
      system("fpm -s dir -t deb -a all -C pkg -v #{version} -n #{name} -d java-runtime-headless --prefix / \
        --license 'Apache-2.0' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq vzw' \
        --description 'Commandline interface to Jenkins' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r('pkg', :force => true)
      FileUtils.rm_r('WEB-INF', :force => true)
      FileUtils.rm(Dir.glob("#{name}_*_all.deb"))
      FileUtils.rm('jenkins.war', :force => true)
    }
  end
end
