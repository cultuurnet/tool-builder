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
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.11.1 multi_json")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 1.0.2 jmespath")
      system("fpm -s gem -t deb -m 'Infra publiq <infra@publiq.be>' -d ruby -v 2.1.2 aws-sdk-core")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
