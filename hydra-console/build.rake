namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("git clone https://github.com/lanthaler/HydraConsole.git hydra-console")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("cd hydra-console; composer install")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_artifact => [:build] do |task|
    require 'time'

    FileUtils.cd task.name.split(':')[0] {
      date = DateTime.now.strftime(format='%Y%m%d%H%M%S')
      ref = `git show-ref -s refs/heads/master`[0..6]
      version = "#{date}+sha.#{ref}"

      system("fpm -s dir -t deb -n hydra-console -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -a all -x \".git\" -x \".gitignore\" \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'Hydra Console is a generic client for Hydra-powered Web APIs.' \
	      --prefix /var/www hydra-console")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("hydra-console", :force => true)
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
