require_relative 'spec_helper'

require 'user'

describe User do

	before(:each) do
		User.all.each{|user| user.destroy}
	end

	after(:each) do
		User.all.each{|user| user.destroy}
	end


	#-----------------------------
	# USED METHODS
	#-----------------------------
	describe "Used methods" do

		it "should have the login" do
			subject.should respond_to :login
		end

		it "should have the password" do
			subject.should respond_to :password
		end
	
	end	



	#-----------------------------
	# VALID? METHOD
	#-----------------------------
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
	
	#-----------------------------
	# FIND BY LOGIN METHOD
	#-----------------------------
  describe "Find by login" do

		describe "The login exists" do

			it "should return false if the authentication fails" do
				User.find_by_login('toto').should == nil
			end

		end

		describe "The login doesn't exist" do

			it "should return true if the authentication succeeds" do
				subject.login = "Thib"
		    subject.password = "pass1"
		    subject.save
				User.find_by_login('Thib').should_not be_nil
			end

		end

  end


	#-----------------------------
	# PASSWORD
	#-----------------------------
	describe "Check Password" do

		before (:each) do
			subject.login = "Thib"
			subject.save
		end

		after(:each) do
			subject.destroy
		end

		it "should encrypt the password with sha1" do
		  Digest::SHA1.should_receive(:hexdigest).with("foo").and_return("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")
		  subject.password="foo"
			subject.password.should == "\"0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33\""
  	end

		it "should store she sha1 digest" do
		  subject.password="foo"
		  subject.password.should == "\"0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33\""
		end

	end

	#----------------------
	# USER AUTHENTICATION
	#----------------------
	describe "User Authentication" do

		before (:each) do
			subject.login = "Thib"
			subject.save
			subject.stub(:login).and_return("foo")
			subject.stub(:password).and_return("\"0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33\"")
		end

		after(:each) do
			subject.destroy
		end

		describe "Valid authentication" do

			it "should know the user" do
				User.should_receive(:find_by_login).with("Thib").and_return(subject)
				User.user_exists("Thib", "foo").should be_true
			end

		end

		describe "Invalid authentication" do

			it "should not know the user because of wrong password" do
				User.should_receive(:find_by_login).with("Thib").and_return(@user)
				User.user_exists("Thib", "toto").should be_false
			end

			it "should not know the user because of wrong login" do
				User.should_receive(:find_by_login).with("ThibThib").and_return(@user)
				User.user_exists("ThibThib", "foo").should be_false
			end

		end



end

	

	


end
