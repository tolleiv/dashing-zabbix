require 'zabby'
require 'json'
require 'active_support/core_ext/numeric/time'
require_relative '../zabbix_credentials'

Dir[File.dirname(__FILE__) + '../lib/trigger_*.rb'].each { |file| require file }

states = {
  2 => TriggerClass.new(:warning),
  3 => TriggerClass.new(:average),
  4 => TriggerClass.new(:high),
  5 => TriggerClass.new(:disaster),
  99 => TriggerClass.new(:total)
}

list = TriggerList.new(states, ZabbixCredentials::SERVER)

SCHEDULER.every '10s' do

  serv = Zabby.init do
    set server: ZabbixCredentials::SERVER
    set user: ZabbixCredentials::USERNAME
    set password: ZabbixCredentials::PASSWORD
    login
  end

  env = serv.run do
    Zabby::Trigger.get(
      'filter' => { 'priority' => states.keys },
      'output' => 'extend',
      'only_true' => 'true',
      'monitored' => 1,
      'selectItems' => 1,
      'withUnacknowledgedEvents' => 1,
      'skipDependent' => 1,
			'selectHosts' => 'extend'
    )
  end

  pas = JSON.parse(env.to_json)
  pas.each do |res|
    # Skip status "ok"
    next if res['value'].to_i == 0

    list.push(res)

    states[res['priority'].to_i].push(res['hosts'][0]['name'])
    states[99].push(res['hosts'][0]['name'])
    # , Time.at(res["lastchange"].to_i), Time.now - 24.hours
  end

  states.each_value do |obj|
    send_event("numbers_#{obj.name}", obj.numbers)
    send_event("items_#{obj.name}",  items: obj.items)
    obj.reset!
  end

  send_event('trigger_list',  items: list.sorted_list)
  send_event('trigger_groups',  items: list.sorted_groups)
  list.reset!
end
