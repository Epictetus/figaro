require "spec_helper"

describe "Figaro Rake tasks", :rake => true do
  describe "figaro:heroku" do
    it "configures Heroku" do
      Figaro.stub(:env => {"HELLO" => "world", "FOO" => "bar"})
      Kernel.should_receive(:system).once.with("heroku config:add FOO=bar HELLO=world")
      task.invoke
    end

    it "configures a specific Heroku app" do
      Figaro.stub(:env => {"HELLO" => "world", "FOO" => "bar"})
      Kernel.should_receive(:system).once.with("heroku config:add FOO=bar HELLO=world --app my-app")
      task.invoke("my-app")
    end
  end

  describe "figaro:travis" do
    let(:travis_path){ ROOT.join("tmp/.travis.yml") }
    let(:rsa){ OpenSSL::PKey::RSA.generate(1024) }
    let(:public_key){ rsa.public_key.to_s }
    let(:private_key){ rsa.to_pem }

    before do
      Rails.stub(:root => ROOT.join("tmp"))
      Kernel.should_receive(:system).with("git remote --verbose").and_return(<<-EOF)
origin\tgit@github.com:bogus/repo.git (fetch)
origin\tgit@github.com:bogus/repo.git (push)
EOF
      stub_request(:get, "http://travis-ci.org/bogus/repo.json").to_return(:body => JSON.generate({"public_key" => public_key}))
    end

    after do
      travis_path.delete if travis_path.exist?
    end

    def write_travis_yml(content)
      travis_path.open("w"){|f| f.write(content) }
    end

    def travis_yml
      YAML.load(travis_path.read)
    end

    context "with no .travis.yml" do
      it "creates .travis.yml" do
        task.invoke
        travis_path.should exist
      end

      it "adds encrypted vars to .travis.yml env" do
        Figaro.stub(:env => {"HELLO" => "world", "FOO" => "bar"})
        task.invoke
        encrypted = travis_yml["env"]["secure"]
        decoded = Base64.decode64(encrypted)
        decrypted = rsa.private_decrypt(decoded)
        decrypted.should == "FOO=bar HELLO=world"
      end

      it "merges additional vars"
    end

    context "with no env in .travis.yml" do
      it "appends env to .travis.yml"

      it "merges additional vars"
    end

    context "with existing env in .travis.yml" do
      it "merges into existing .travis.yml env(s)"

      it "merges additional vars"
    end
  end
end
