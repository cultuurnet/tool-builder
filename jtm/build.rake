namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget https://github.com/ldn-softdev/jtm/raw/master/jtm-linux-64.v2.09 -O jtm")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.chmod(0755, "jtm", :verbose => true)
      FileUtils.mkdir_p("build")
      FileUtils.mv("jtm", "build")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = `build/jtm -h`[/^Version (.*), .*/, 1]
      system("fpm -s dir -t deb -a all -v #{version} -n jtm --prefix /usr/bin \
        --license 'Apache-2.0' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq VZW' -a native \
        --description 'Easy lossless HTML/XML to JSON and back converter cli utility' -C build .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("build", :force => true)
      FileUtils.rm(Dir.glob("jtm_*.deb"))
      FileUtils.rm(Dir.glob("jtm"))
    }
  end
end
