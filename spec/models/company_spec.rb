require 'spec_helper'

describe Company do
  describe "before create" do
    it "will set code for the company by removing non alphanumeric" do
      company = Company.create(:name => "yahoo inc, Com. ")
      company.code.should eq("yahooinccom")
    end

    it "will set code for the company by downcasing" do
      company = Company.create(:name => "Yahoo Inc, Com. ")
      company.code.should eq("yahooinccom")
    end
  end

  describe "retrieve_company method" do
    it "will find code by codifying the given arguement" do
      Company.should_receive(:find_by_code).with("microsoft").and_return("some")
      Company.retrieve_by_code("Micro, Soft.").should eq("some")
    end
  end
end
