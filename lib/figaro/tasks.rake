require "json"
require "openssl"
require "base64"

namespace :figaro do
  desc "Configure Heroku according to application.yml"
  task :heroku, [:app] => :environment do |_, args|
    vars = Figaro.env.map{|k,v| "#{k}=#{v}" }.sort.join(" ")
    command = "heroku config:add #{vars}"
    command << " --app #{args[:app]}" if args[:app]
    Kernel.system(command)
  end

  desc "Configure Travis according to application.yml"
  task :travis, [:vars] => :environment do
    remotes = Kernel.system("git remote --verbose")
    match = remotes.match(/git@github\.com:([^\s]+)/)
    slug = match && match[1].sub(/\.git$/, "")
    json = Net::HTTP.get("travis-ci.org", "/#{slug}.json")
    public_key = JSON.parse(json)["public_key"]
    rsa = OpenSSL::PKey::RSA.new(public_key)
    vars = Figaro.env.map{|k,v| "#{k}=#{v}" }.sort.join(" ")
    secure = Base64.encode64(rsa.public_encrypt(vars)).rstrip
    yaml = YAML.dump("env" => {"secure" => secure})
    Rails.root.join(".travis.yml").open("w"){|f| f.write(yaml) }
  end
end
