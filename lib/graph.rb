class Graph
  attr_accessor :year, :month

  def initialize(year, month)
    @year, @month = year.to_i, month.to_i
  end

  def graph_data
    serie = Transaction.
      filter(:reported_on => range_for_month).
      filter('amount < 0').
      group_by(:tag).
      select(:tag.as('tag'), :SUM[:amount].as('amount')).
      map{|t| [t.tag.to_s == "" ? 'Other' : t.tag.to_s, t.amount.to_f.abs] }
    serie
  end

  def tag_from_pos(x, y)
    graph_data.each_with_index do |(tag, amount), idx|
      return tag if (idx..idx+1).include?(x) && (0..amount).include?(y)
    end
    false
  end

  def range_for_month
    from = Time.mktime(@year, @month, 1)
    to = Time.mktime(@year + (@month == 12 ? 1 : 0), @month == 12 ? 1 : @month + 1, 1) - 1
    from..to
  end

  def transactions(tag = nil)
    where = {}
    where[:reported_on] = range_for_month
    where[:tag] = tag if tag
    Transaction.filter(where).all
  end
  
  def to_json
    data, ticks, pos = [], [], 0
    graph_data.each do |tick, amount|
      data << [pos, amount]
      ticks << [pos + 0.5, tick]
      pos += 2
    end
    JSON.generate :ticks => ticks, :data => data    
  end
end
