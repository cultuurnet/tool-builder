namespace = File.basename(File.expand_path("..", __FILE__))

version = (ENV['version'].nil? or ENV['version'].empty?) ? '4.9.0' : ENV['version']
name = 'solr'
download_url = "http://archive.apache.org/dist/lucene/#{name}/#{version}/#{name}-#{version}.tgz"

namespace "#{namespace}" do
  desc "Download the necessary sources for the version specified."
  task :download => [:clean] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("wget #{download_url}")
    }
  end

  desc "Create binaries from the source code."
  task :build => [:download] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("tar xzf #{name}-#{version}.tgz")
      FileUtils.mkdir_p('pkg/opt')
      FileUtils.mkdir_p('pkg/etc/init.d')
      FileUtils.mkdir_p('pkg/etc/default')
      FileUtils.mv("#{name}-#{version}/example", 'pkg/opt/solr')
      FileUtils.mkdir('pkg/opt/solr/example')
      FileUtils.mv('pkg/opt/solr/solr/collection1', 'pkg/opt/solr/example')
      FileUtils.mv('pkg/opt/solr/example/collection1/core.properties', 'pkg/opt/solr/example/collection1/core.properties.example')
      FileUtils.mv('pkg/opt/solr/example/collection1/conf/schema.xml', 'pkg/opt/solr/example/collection1/conf/schema.xml.example')
      FileUtils.mv('pkg/opt/solr/example/collection1/conf/solrconfig.xml', 'pkg/opt/solr/example/collection1/conf/solrconfig.xml.example')
      FileUtils.cp('init.d/solr', "pkg/etc/init.d/solr")
      FileUtils.cp('default/solr', "pkg/etc/default/solr")
    }
  end

  desc "Create a debian package from the binaries."
  task :build_package => [:build] do |task|
    FileUtils.cd task.name.split(':')[0] {
      system("fpm -s dir -t deb -n #{name} -v #{version} -C pkg\
        -m 'Infra CultuurNet <infra@cultuurnet.be>' -a all \
        --url 'http://www.cultuurnet.be' --vendor 'CultuurNet Vlaanderen' \
        --description 'Solr is an open source search platform built on Apache Lucene' \
        --before-install preinst --before-remove prerm --after-remove postrm \
	      --deb-user solr --deb-group solr -d java-runtime-headless --prefix / ." )
    }
  end

  desc "Remove generated files."
  task :clean do |task|
    FileUtils.cd task.name.split(':')[0] {
      FileUtils.rm_r(Dir.glob("#{name}-#{version}*"), :force => true)
      FileUtils.rm_r(Dir.glob("pkg"), :force => true)
      FileUtils.rm(Dir.glob("*.deb"), :force => true)
    }
  end
end
