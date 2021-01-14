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
      FileUtils.mkdir_p("pkg")
      FileUtils.mkdir_p("pkg/usr/local/share/ca-certificates/publiq")
      FileUtils.cp_r(Dir.glob("*.crt"),"pkg/usr/local/share/ca-certificates/publiq")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version = Time.now.strftime("%Y%m%d%H%M%S")
      system("fpm -s dir -t deb -a all -C pkg -v #{version} -n ca-certificates-publiq --prefix / \
        --license 'Apache-2.0' -m 'Infra publiq <infra@publiq.be>' \
        --url 'https://www.publiq.be' --vendor 'publiq VZW' \
	      --after-install postinst --after-remove postrm \
        --description 'publiq root certificates' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("pkg", :force => true)
      FileUtils.rm(Dir.glob("ca-certificates-publiq_*_all.deb"))
    }
  end
end
