class String
  def to_transaction_s
    self.gsub(/\./,'_').gsub(/,/,'.')
  end
end
class Transaction < Sequel::Model
  before_save :set_auto_tag
  validates_uniqueness_of [:reported_on, :transferred_on, :verification, :description, :amount, :balance]
  
  set_schema do
    primary_key :id
    date :reported_on
    date :transferred_on
    string :verification
    string :description
    float :amount
    float :balance
    string :tag
  end

  def self.import_data(tabbed_data)
    return_number_of_inserted_rows do
      tabbed_data.split(/\n/).each do |line|
        next if line.empty?
        reported_on, transferred_on, verification, description, amount, balance = line.split(/\t/)
        create_when_valid(:reported_on => reported_on, :transferred_on => transferred_on, :verification => verification,
          :description => description, :amount => amount.to_transaction_s, :balance => balance.to_transaction_s)
      end
    end
  end
  
  def self.create_when_valid(*args)
    transaction = new(*args)
    transaction.save if transaction.valid?
  end

  def self.return_number_of_inserted_rows
    before_work_count = Transaction.count
    yield
    Transaction.count - before_work_count
  end
  
  def self.page_size
    20
  end
  
  def self.tags
    Transaction.select(:tag).uniq.order(:tag).map(&:tag).uniq
  end
  
  # Transaction.filter(:reported_on => Time.parse("2008-11-01")..(Time.parse("2008-12-01")-1) ).print
                          
  def set_auto_tag
    self.tag ||= case description
    when /^Coop Nära/, /^Oj Helsingb/, /(^|\s)Ica(\s|$)/
      'Mat'
    when /(^|\s)Aut\d{2}.+?\d{2}$/
      'Uttag'
    when /Mcdonalds/, /Burger King/, /Pizzeria Cle/
      'Snabbmat'
    when /Clarion Gran/, /Systembolage/
      'Nöje'
    when /Apoteket Sho/
      'Vård'
    end
    true
  end

end

Transaction.create_table unless Transaction.table_exists?
