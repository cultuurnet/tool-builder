namespace = File.basename(File.expand_path("..", __FILE__))

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
      system("fpm -s python -t deb -n python3-pyyaml \
        -m 'Infra publiq <infra@publiq.be>' -d 'python3' \
        --url 'https://www.publiq.be' --vendor 'publiq vzw' \
        --python-package-name-prefix python3 --python-bin python3 \
        --python-easyinstall easy_install3 --no-python-fix-name \
	pyyaml")
      system("fpm -s python -t deb -n python3-pykwalify \
        -m 'Infra publiq <infra@publiq.be>' -d 'python3' \
        --url 'https://www.publiq.be' --vendor 'publiq vzw' \
        --python-package-name-prefix python3 --python-bin python3 \
        --python-easyinstall easy_install3 --no-python-fix-name \
	pykwalify")
      system("fpm -s python -t deb -n python3-borgmatic \
        -m 'Infra publiq <infra@publiq.be>' -d 'python3' \
        --url 'https://www.publiq.be' --vendor 'publiq vzw' \
        --python-package-name-prefix python3 --python-bin python3 \
        --python-easyinstall easy_install3 --no-python-fix-name -v 1.0.3 \
	borgmatic")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
