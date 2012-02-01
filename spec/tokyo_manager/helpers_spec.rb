require 'spec_helper'

describe TokyoManager::Helpers do
  subject do
    Object.new.tap do |object|
      object.extend TokyoManager::Helpers
    end
  end

  describe "master_port_for_date" do
    it "returns the correct port" do
      subject.master_port_for_date(Date.new(2012, 2, 1)).should eq(10505)
      subject.master_port_for_date(Date.new(2011, 12, 1)).should eq(10503)
    end
  end

  describe "slave_port_for_date" do
    it "returns the correct port" do
      subject.slave_port_for_date(Date.new(2012, 2, 1)).should eq(12505)
      subject.slave_port_for_date(Date.new(2011, 12, 1)).should eq(12503)
    end
  end

  describe "linux?" do
    context "when using os x" do
      before do
        subject.stub(:platform).and_return('darwin')
      end

      it { should_not be_linux }
    end

    context "when using linux" do
      before do
        subject.stub(:platform).and_return('linux')
      end

      it { should be_linux }
    end
  end

  describe "darwin?" do
    context "when using os x" do
      before do
        subject.stub(:platform).and_return('darwin')
      end

      it { should be_darwin }
    end

    context "when using linux" do
      before do
        subject.stub(:platform).and_return('linux')
      end

      it { should_not be_darwin }
    end
  end
end
