namespace = File.basename(File.expand_path("..", __FILE__))
version_string = (ENV['version'].nil? or ENV['version'].empty?) ? '' : "-v #{ENV['version']}"

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
  task :build_artifact => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby #{version_string} fpm")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
