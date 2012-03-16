require_relative 'spec_helper'

require 'application'

describe Application do

  subject do
    Application.new
  end

  describe "Valid?" do

		before(:each) do	
			User.all.each{|user| user.destroy}
			Application.all.each{|appli| appli.destroy}
		end

		after(:each) do
			User.all.each{|user| user.destroy}
			Application.all.each{|appli| appli.destroy}
		end

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
			subject.user_id = "12"
      subject.save
      appli = Application.new
      appli.name = "Appli2"
      appli.url = "http://www.url1.fr/"
			subject.user_id = "12"
      appli.valid?.should be_false
			subject.destroy
    end

    it "should not be valid with two identical names" do
	 		subject.name = "AppliTest"
      subject.url = "http://www.urlTest1.fr/"
			subject.user_id = "12"
      subject.save
      appli = Application.new
      appli.name = "AppliTest"
      appli.url = "http://www.urlTest2.fr/"
			subject.user_id = "12"
      appli.valid?.should be_false
    end

    it "should not be valid with two identical names and urls" do
	 		subject.name = "Appli"
      subject.url = "http://www.url.fr/"
			subject.user_id = "12"
      subject.save
      appli = Application.new
      appli.name = "Appli"
      appli.url = "http://www.url.fr/"
			subject.user_id = "12"
      appli.valid?.should be_false
    end


		describe "Store the user id" do

			before(:each) do
				subject.name = "Appli"
		    subject.url = "http://www.url.fr/"
			end

			it "should not store something different than an integer as user id" do
				subject.user_id = "toto33"
		    subject.save
				subject.valid?.should be_false
			end

			it "should not store an integer as user id" do
				subject.user_id = "12"
		    subject.save
				subject.valid?.should be_true
			end

		end

  end

	describe "Delete an application" do

		before(:each) do
			@paramsUser1 = {'login' => 'tmomo','password' => 'passwordThib'}
			User.create(@paramsUser1)
			@paramsUser2 = {'login' => 'toto','password' => 'pwdToto'}
			User.create(@paramsUser2)
			@paramsAppli = {'name' => 'nomAppli','url' => 'http://urlAppli.fr'}
			@user1 = User.find_by_login('tmomo')
			@user2 = User.find_by_login('toto')
			Application.create('name' => 'nomAppli','url' => 'http://urlAppli.fr','user_id' => @user1.id)
			@appli = Application.find_by_name('nomAppli')
		end

		after(:each) do
			#User.all.each{|user| user.destroy}
			#Application.all.each{|appli| appli.destroy}
		end

		it "should delete a known application selected by the owner" do
			Application.delete(@appli.id, @user1.login)
			Application.find_by_id(@appli.id).should be_nil
		end
		
		it "should not delete a known application selected by someone who is not the owner" do
			Application.delete(@appli.id, @user2.login)
			Application.find_by_id(@appli.id).should_not be_nil
		end

		it "should not delete an application which doesn't exist" do
			Application.delete('9999999', @user1.login)
			Application.find_by_id('9999999').should be_nil
		end

					

	end


	


end
