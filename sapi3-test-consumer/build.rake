namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("git clone https://github.com/cultuurnet/sapi3-test-consumer")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd "#{task.name.split(':')[0]}/sapi3-test-consumer" do
      system("npm install")
      system("cd public; bower install")
      system("composer install --ignore-platform-reqs --prefer-dist --optimize-autoloader")
    end
  end

  desc "Create a debian package from the binaries."
  task :build_artifact => [:build] do |task|
    require 'time'

    FileUtils.cd task.name.split(':')[0] do
      date = DateTime.now.strftime(format='%Y%m%d%H%M%S')
      ref = `cd sapi3-test-consumer; git show-ref -s refs/heads/master`[0..6]
      version = "#{date}+sha.#{ref}"

      system("fpm -s dir -t deb -n sapi3-test-consumer -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -a all -x \".git\" -x \".gitignore\" \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'Test consumer for UiTDatabank 3 search' \
	      --prefix /var/www -d 'php7.1-cli' sapi3-test-consumer")
    end
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("sapi3-test-consumer", :force => true)
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
