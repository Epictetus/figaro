require "spec_helper"

describe Figaro::Env do
  before do
    ENV["HELLO"] = "world"
  end

  after do
    ENV.delete("HELLO")
  end

  it "makes ENV values accessible as methods" do
    subject.HELLO.should == "world"
  end

  it "makes lowercase ENV values accessible as methods" do
    subject.hello.should == "world"
  end

  it "raises an error if no ENV key matches" do
    expect { subject.goodbye }.to raise_error(NoMethodError)
  end
end
