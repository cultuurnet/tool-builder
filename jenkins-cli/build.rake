package_namespace = File.basename(File.expand_path("..", __FILE__)).to_sym

name = 'jenkins-cli'
download_host = "https://mirrors.jenkins.io"

namespace package_namespace do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget #{download_host}/war-stable/latest/jenkins.war")
      system("jar xf jenkins.war META-INF/MANIFEST.MF")
      version = File.read('META-INF/MANIFEST.MF')[/^Jenkins-Version: (.*)$/, 1].strip
      system("wget #{download_host}/debian-stable/jenkins_#{version}_all.deb")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("pkg/usr/share/#{name}")
      FileUtils.mkdir_p("pkg/usr/bin")

      system("jar xf jenkins.war $(jar tf jenkins.war | grep 'WEB-INF/lib/cli-')")
      system("cp WEB-INF/lib/cli-*.jar pkg/usr/share/#{name}/cli.jar")
      system("install -m 0755 #{name} pkg/usr/bin/#{name}")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = `ls WEB-INF/lib`[/cli\-(.+)\.jar/, 1]
      iteration = `date '+%Y%m%d%H%M%S'`.chomp
      system("fpm -s dir -t deb -a all -C pkg -n #{name} -v #{version} \
        --iteration #{iteration} --prefix / \
        --license 'Apache-2.0' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq vzw' \
        --description 'Commandline interface to Jenkins' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r('pkg', :force => true)
      FileUtils.rm_r('META-INF', :force => true)
      FileUtils.rm_r('WEB-INF', :force => true)
      FileUtils.rm(Dir.glob("#{name}_*_all.deb"), :force => true)
      FileUtils.rm(Dir.glob("jenkins_*_all.deb"), :force => true)
      FileUtils.rm('jenkins.war', :force => true)
    }
  end
end
