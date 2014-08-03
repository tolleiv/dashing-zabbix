require 'zabby'
require 'json'
require 'active_support/core_ext/numeric/time'
require_relative '../zabbix_credentials'

class TriggerClass

  attr_reader :name

  def initialize(name)
    @name = name
    @hash = Hash.new(0)
    reset!
  end

  def reset!
    @last_total = numbers()[:current] || 0
    @hash = Hash.new(0)
  end

  def push(name)
    @hash[name] += 1
  end

  def numbers
    total = @hash.values.reduce(0) { |sum, i| sum += i }
    {
      current: total,
      last: @last_total,
      status: total > 0 ? @name.to_s : "ok"
    }
  end

  def items
    list = []
    @hash.each { |key, value| list.push({label: key, value: value}) }
    list.sort! { |x, y| x[:value] <=> y[:value] }
    list.delete_if { |x| x[:value] < 1 }
    list.reverse
  end

end

states = {
  2 => TriggerClass.new(:warning),
  3 => TriggerClass.new(:average),
  4 => TriggerClass.new(:high),
  5 => TriggerClass.new(:disaster)
}

SCHEDULER.every '10s' do

  serv = Zabby.init do
    set :server => ZabbixCredentials::SERVER
    set :user => ZabbixCredentials::USERNAME
    set :password => ZabbixCredentials::PASSWORD
    login
  end

  env = serv.run {
    Zabby::Trigger.get(
      "filter" => {"priority" => states.keys},
      "output" => "extend",
      "only_true" => "true",
      "monitored" => 1,
      "withUnacknowledgedEvents" => 1,
      "skipDependent" => 1,
      "expandData" => "host"
    )
  }

  pas = JSON.parse(env.to_json)
  pas.each do |res|
    # Skip status "ok"
    next if res["value"].to_i == 0

    states[res["priority"].to_i].push(res["hostname"])
    # , Time.at(res["lastchange"].to_i), Time.now - 24.hours
  end

  states.each_value do |obj|
    send_event("numbers_#{obj.name.to_s}", obj.numbers)
    send_event("items_#{obj.name.to_s}", {items: obj.items})
    obj.reset!
  end

end