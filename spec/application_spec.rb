require_relative 'spec_helper'

require 'application'

describe Application do

  subject do
    Application.new
  end

	before(:each) do
		Application.all.each{|appli| appli.destroy}
	end

	after(:each) do
		Application.all.each{|appli| appli.destroy}
	end

  describe "Valid?" do

    it "should not be valid without an url" do
	 		subject.name = "NomAppli"
      subject.user_id = "12"
      subject.valid?.should be_false
    end

		it "should not be valid with an empty name" do
			subject.name = ""
			subject.url = "http://www.url.fr/"
      subject.user_id = "12"
			subject.valid?.should be_false
		end

    it "should not be valid without a name" do
	 		subject.url = "http://www.url.fr/"
      subject.user_id = "12"
      subject.valid?.should be_false
    end

		it "should not be valid with an empty url" do
			subject.name = "NomAppli"
			subject.url = ""
      subject.user_id = "12"
			subject.valid?.should be_false
		end

    it "should not be valid without a name and an url" do
      subject.user_id = "12"
      subject.valid?.should be_false
    end

		it "should not be valid without the user id" do
			subject.name = "NomAppli"
			subject.url = ""
      subject.valid?.should be_false
		end

    it "should not be valid with two identical urls" do
	 		subject.name = "Appli1"
      subject.url = "http://www.url1.fr/"
      subject.save
      appli = Application.new
      appli.name = "Appli2"
      appli.url = "http://www.url1.fr/"
      appli.valid?.should be_false
			subject.destroy
    end

    it "should not be valid with two identical names" do
	 		subject.name = "AppliTest"
      subject.url = "http://www.urlTest1.fr/"
      subject.save
      appli = Application.new
      appli.name = "AppliTest"
      appli.url = "http://www.urlTest2.fr/"
      appli.valid?.should be_false
    end

    it "should not be valid with two identical names and urls" do
	 		subject.name = "Appli"
      subject.url = "http://www.url.fr/"
      subject.save
      appli = Application.new
      appli.name = "Appli"
      appli.url = "http://www.url.fr/"
      appli.valid?.should be_false
    end

	

  end

	




end
