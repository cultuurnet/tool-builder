namespace = File.basename(File.expand_path("..", __FILE__))

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      version_string = (ENV['version'].nil? or ENV['version'].empty?) ? "" : "@#{ENV['version']}"
      system("npm install elasticdump#{version_string}")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.mkdir_p("pkg/elasticdump")
      FileUtils.cp_r("node_modules","pkg/elasticdump")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      require 'json'

      ENV['NPM_CONFIG_DEPTH'] = '0'
      ENV['NPM_CONFIG_JSON'] = 'true'
      output = `npm info elasticdump`
      version = JSON.parse(output)['version']
      system("fpm -s dir -t deb -a all -C pkg -v #{version} -n elasticdump -d nodejs --prefix /opt \
        --license 'Apache-2.0' -m 'Infra CultuurNet <infra@cultuurnet.be>' \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --after-install postinst --before-remove prerm  \
        --description 'Import and export tools for Elasticsearch' .")
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r("pkg", :force => true)
      FileUtils.rm_r("node_modules", :force => true)
      FileUtils.rm(Dir.glob("elasticdump_*_all.deb"))
    }
  end
end
