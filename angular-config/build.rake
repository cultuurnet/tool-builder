namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("git clone git@github.com:cultuurnet/angular_config.git")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
    }
  end

  desc "Create a debian package from the binaries."
  task :build_artifact => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("cd angular_config; gem build angular_config.gemspec")
      system("cd angular_config; fpm -s gem -t deb -p .. angular_config*.gem")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("angular_config", :force => true)
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
