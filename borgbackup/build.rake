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
      system("fpm -s python -t deb -n python3-msgpack \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --python-package-name-prefix python3 --python-bin python3 \
        --python-easyinstall easy_install3 --no-python-fix-name \
	msgpack-python")
      system("fpm -s python -t deb -d python3-msgpack \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --python-package-name-prefix python3 --python-bin python3 \
        --python-easyinstall easy_install3 --no-python-dependencies \
	-d python3 -d openssl -d libacl1 -d liblz4-1 -d zlib1g -d liblzma5 \
        -d fuse -d python3-llfuse -d 'python3-msgpack >= 0.4.6' \
	-d python3-pkg-resources \
	borgbackup")
      system("fpm -s python -t deb -d python3-borgbackup \
        --license 'Apache-2.0' -m 'Infra CultuurNet <infra@cultuurnet.be>' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --python-package-name-prefix python3 --python-bin python3 \
        --python-easyinstall easy_install3 \
        atticmatic")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("pkg", :force => true)
      FileUtils.rm("*.deb", :force => true)
    }
  end
end
