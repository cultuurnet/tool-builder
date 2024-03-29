namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("git clone git@github.com:tudelft3d/prepair.git")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd "#{task.name.split(':')[0]}/prepair" do
      system("rm definitions.h")
      system("git checkout improvements-with-ogr")
      system("cmake .")
      system("make")
      system("mkdir ../pkg")
      system("mv prepair ../pkg")
    end
  end

  desc "Create a debian package from the binaries."
  task :build_artifact => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = Time.now.strftime("%Y%m%d%H%M%S")
      system("fpm -s dir -t deb -n prepair -v #{version} \
        -m 'Infra CultuurNet <infra@cultuurnet.be>' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
	      -d libgdal1h -d libcgal10 -d libboost-program-options1.54.0 \
        --prefix /usr/bin -C pkg ."
      )
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("prepair", :force => true)
      FileUtils.rm_r("pkg", :force => true)
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
