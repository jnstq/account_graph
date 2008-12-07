require File.dirname(__FILE__) + '/spec_helper'

describe Graph do

  describe 'generate graph data' do
    
    before(:each) do
      data = %Q{2008-11-10	2008-11-07	5484798059	Clarion Gran	-112,00	11.319,31
      2008-11-10	2008-11-07	5484595656	Pizzeria Cle	-55,00	11.431,31
      2008-11-10	2008-11-07	5484425953	Systembolage	-80,00	11.486,31
      2008-11-10	2008-11-08	5484522526	Apoteket Sho	-100,50	11.566,31}
      Transaction.import_data(data)
      @graph = Graph.new(2008, 11)
    end
    
    it "should generate range for normal month" do
      @graph.range_for_month.should eql(Time.mktime(2008,11,1)..(Time.mktime(2008,12,1) - 1))
    end
    
    it "should generate range for december" do
      @graph.year, @graph.month = 2008, 12
      @graph.range_for_month.should eql(Time.mktime(2008,12,1)..(Time.mktime(2009,1,1) - 1))
    end
    
    it "should return a serie for each tag" do
      @graph = Graph.new(2008, 11)
    end
    
    it "should return array for the data serie" do
      @graph.graph_data.should eql([["Nöje", 192.0],["Snabbmat", 55.0], ["Vård", 100.50]])
    end
    
    it "should return tag for x, y position" do
      @graph.tag_from_pos(0, 150).should eql('Nöje')
    end
    
  end

end
