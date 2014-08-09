# Helper class which groups all entries by serenity
class TriggerClass
  attr_reader :name

  def initialize(name)
    @name = name
    @hash = Hash.new(0)
    reset!
  end

  def reset!
    @last_total = numbers[:current] || 0
    @hash = Hash.new(0)
  end

  def push(name)
    @hash[name] += 1
  end

  def numbers
    total = @hash.values.reduce(0) { |a, e| a + e }
    {
      current: total,
      last: @last_total,
      status: total > 0 ? @name.to_s : 'ok'
    }
  end

  def items
    list = []
    @hash.each { |key, value| list.push(label: key, value: value) }
    list.sort! { |x, y| x[:value] <=> y[:value] }
    list.delete_if { |x| x[:value] < 1 }
    list.reverse
  end
end
