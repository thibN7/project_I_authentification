require_relative 'spec_helper'

require 'user'

describe User do

  subject do
    User.new
  end

  describe "Missing information" do

    it "should not be valid without a password" do
      subject.login = "Thibault"
      subject.save
      subject.valid?.should be_false
    end
    
    it "should not be valid without a login" do
      subject.password = "MotDePasse"
      subject.save
      subject.valid?.should be_false        
    end

    it "should not be valid without a login and a password" do
      subject.save
      subject.valid?.should be_false  
    end
    
  end 


  describe "Wrong information" do

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



end
