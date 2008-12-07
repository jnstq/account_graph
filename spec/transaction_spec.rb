require File.dirname(__FILE__) + '/spec_helper'

describe Transaction do

  before(:each) do
    @transacton = Transaction.new
  end

  describe 'generate auto tag' do

    it "should auto tag 'Coop Nära Ör' to 'Mat" do
      @transacton.should auto_tag('Coop Nära Ör').to('Mat')
    end

    it "should auto tag 'Oj Helsingb' to 'Mat" do
      @transacton.should auto_tag('Oj Helsingb').to('Mat')
    end

    it "should auto tag 'Ica' to 'Mat" do
      @transacton.should auto_tag('Maxi Ica Sto').to('Mat')
    end

    it "should auto tag 'Aut14:34' to 'Uttag'" do
      @transacton.should auto_tag('Aut14:34').to('Uttag')
    end

    it "should auto tag 'Burger King' to 'Snabbmat'" do
      @transacton.should auto_tag('Burger King').to('Snabbmat')
    end

    it "should auto tag 'Mcdonalds' to 'Snabbmat'" do
      @transacton.should auto_tag('Mcdonalds').to('Snabbmat')
    end

    it "should auto tag 'Pizzeria Cle' to 'Snabbmat'" do
      @transacton.should auto_tag('Pizzeria Cle').to('Snabbmat')
    end
    
    it "should auto tag 'Clarion Gran' to 'Nöje'" do
      @transacton.should auto_tag('Clarion Gran').to('Nöje')
    end
    
    it "should auto tag 'Systembolage' to 'Nöje'" do
      @transacton.should auto_tag('Systembolage').to('Nöje')
    end
    
    it "should auto tag 'Apoteket Sho' to 'Vård'" do
      @transacton.should auto_tag('Apoteket Sho').to('Vård')
    end

  end

  describe 'import data' do

    before(:each) do
      @data = <<-EOF
      2008-11-10	2008-11-07	5484798059	Clarion Gran	-112,00	11.319,31
      2008-11-10	2008-11-07	5484595656	Pizzeria Cle	-55,00	11.431,31
      EOF
    end

    it "should import data" do
      lambda {
        Transaction.import_data(@data)
      }.should change(Transaction, :count).by(2)
    end

    it "should import reported on column" do
      Transaction.import_data(@data)
      Transaction.first.reported_on.should eql(Time.parse('2008-11-10'))
    end

    it "should import transferred on column" do
      Transaction.import_data(@data)
      Transaction.first.transferred_on.should eql(Time.parse('2008-11-07'))
    end

    it "should insert verification number" do
      Transaction.import_data(@data)
      Transaction.first.verification.should eql('5484798059')
    end

    it "should insert description" do
      Transaction.import_data(@data)
      Transaction.first.description.should eql('Clarion Gran')
    end

    it "should insert amount" do
      Transaction.import_data(@data)
      Transaction.first.amount.should eql(-112.0)
    end

    it "should insert balace" do
      Transaction.import_data(@data)
      Transaction.first.balance.should eql(11319.31)
    end

    it "should generate auto tag" do
      Transaction.import_data(@data)
      Transaction.all.last.tag.should eql('Snabbmat')
    end

    it "should only allow uniq verification" do
      lambda {
        Transaction.import_data(@data)
        Transaction.import_data(@data)
      }.should change(Transaction,:count).by(2)
    end
    
    it "should return number of rows inserted" do
      Transaction.import_data(@data).should eql(2)
    end
    
    it "should error 'invalid value for Float(): \-3.045.00\'" do
      data = "2008-10-29	2008-10-28	5484678971	Elektro Koll	-2.9,00	26.115,50"
      lambda {
        Transaction.import_data(data)
      }.should change(Transaction,:count).by(1)      
    end

  end

end
