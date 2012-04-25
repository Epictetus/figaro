require "spec_helper"
require "active_support/core_ext/string/strip"

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
    let(:travis_yml){ YAML.load_file(travis_path) }
    let(:decrypted){ decrypt(travis_yml["env"]) }

    def decrypt(value)
      case value
      when Hash then rsa.private_decrypt(Base64.decode64(value["secure"]))
      when Array then value.map{|v| decrypt(v) }
      end
    end

    before do
      FileUtils.mkdir_p(ROOT.join("tmp"))
      Figaro.stub(:env => {"HELLO" => "world", "FOO" => "bar"})
      Rails.stub(:root => ROOT.join("tmp"))
      Kernel.should_receive(:system).with("git remote --verbose").and_return("origin\tgit@github.com:bogus/repo.git (fetch)\norigin\tgit@github.com:bogus/repo.git (push)")
      stub_request(:get, "http://travis-ci.org/bogus/repo.json").to_return(:body => JSON.generate({"public_key" => public_key}))
    end

    after do
      travis_path.delete if travis_path.exist?
      FileUtils.rm_r(ROOT.join("tmp"))
    end

    context "with no .travis.yml" do
      it "creates .travis.yml" do
        task.invoke
        travis_path.should exist
      end

      it "adds encrypted vars to .travis.yml env" do
        task.invoke
        decrypted.should == "FOO=bar HELLO=world"
      end

      it "merges additional vars" do
        task.invoke("LASER=lemon FOO=baz")
        decrypted.should == "FOO=baz HELLO=world LASER=lemon"
      end
    end

    def write_travis_yml(content)
      travis_path.open("w"){|f| f.write(content) }
    end

    context "with no env in .travis.yml" do
      before do
        write_travis_yml(%(language: "ruby"))
      end

      it "appends env to .travis.yml" do
        task.invoke
        decrypted.should == "FOO=bar HELLO=world"
        travis_yml["language"].should == "ruby"
      end

      it "merges additional vars" do
        task.invoke("LASER=lemon FOO=baz")
        decrypted.should == "FOO=baz HELLO=world LASER=lemon"
        travis_yml["language"].should == "ruby"
      end

      it "preserves existing formatting" do
        task.invoke
        File.read(travis_path).should match /^language: "ruby"/
      end
    end

    context "with env in .travis.yml" do
      it "clobbers a single env" do
        write_travis_yml(<<-EOF.strip_heredoc)
          env: LASER=tag
          language: "ruby"
          EOF
        task.invoke
        decrypted.should == "FOO=bar HELLO=world"
        File.read(travis_path).rstrip.should == <<-EOF.strip_heredoc.rstrip
          language: "ruby"
          env: {secure: #{travis_yml["env"]["secure"]}}
          EOF
      end

      it "clobbers multiple envs" do
        write_travis_yml(<<-EOF.strip_heredoc)
          env:
            - LASER=tag
            - LEMON=zest
          language: "ruby"
          EOF
        task.invoke
        decrypted.should == "FOO=bar HELLO=world"
        File.read(travis_path).rstrip.should == <<-EOF.strip_heredoc.rstrip
          language: "ruby"
          env: {secure: #{travis_yml["env"]["secure"]}}
          EOF
      end
    end
  end
end
