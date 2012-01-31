require 'spec_helper'

describe TokyoManager::Configuration do
  subject do
    Object.new.tap do |object|
      object.extend TokyoManager::Configuration
    end
  end

  context "when rails is present" do
    let(:rails) { { 'host' => 'rails_host' } }

    before do
      subject.stub(:rails_configuration).and_return(rails)
    end

    describe "host" do
      it "returns the value from the rails configuration" do
        subject.host.should eq('rails_host')
      end
    end

    describe "default_port" do
      context "when the port is defined in the rails configuration" do
        before do
          rails['port'] = 12345
        end

        it "returns the value from the rails configuration" do
          subject.default_port.should eq(12345)
        end
      end

      context "when the port is not defined in the rails configuration" do
        it "returns 1978" do
          subject.default_port.should eq(1978)
        end
      end
    end
  end

  context "when rails is not present" do
    describe "host" do
      it "returns 'localhost'" do
        subject.host.should eq('localhost')
      end
    end

    describe "default_port" do
      it "returns 1978" do
        subject.default_port.should eq(1978)
      end
    end
  end
end
