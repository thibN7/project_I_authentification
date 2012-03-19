require_relative 'spec_helper'

require 'user'

describe User do

  subject do
    User.new
  end

	before(:each) do
		User.all.each{|user| user.destroy}
	end

	after(:each) do
		User.all.each{|user| user.destroy}
	end

  describe "Valid?" do

    it "should not be valid without a password" do
      subject.login = "Thibault"
      subject.valid?.should be_false
    end

		it "should not be valid with an empty password" do
			subject.login = "Thibault"
			subject.password = ""
      subject.valid?.should be_false
		end
    
    it "should not be valid without a login" do
      subject.password = "MotDePasse"
      subject.valid?.should be_false        
    end

		it "should not be valid with an empty login" do
			subject.login = ""
			subject.password = "MotDePasse"
      subject.valid?.should be_false
		end

    it "should not be valid without a login and a password" do
      subject.valid?.should be_false  
    end

    it "should not be valid with two identical logins" do
      subject.login = "Thib"
      subject.password = "pass1"
      subject.save
      user1 = User.new
      user1.login = "Thib"
      user1.password = "pass1"
      user1.valid?.should be_false
    end
    
  end 


  describe "Find by login" do

		it "should return false if the authentication fails" do
			User.find_by_login('toto').should == nil
		end
	
		it "should return true if the authentication succeeds" do
			subject.login = "Thib"
      subject.password = "pass1"
      subject.save
			User.find_by_login('Thib').should_not == nil
		end

  end

	describe "Password" do

		it "should encrypt the password with sha1" do
		  Digest::SHA1.should_receive(:hexdigest).with("foo").and_return("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")
		  subject.password="foo"
  	end

		it "should store she sha1 digest" do
		  subject.password="foo"
		  subject.password.should == "\"0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33\""
		end

	end



	

	


end
