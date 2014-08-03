require 'zabby'
require 'json'
require 'active_support/core_ext/numeric/time'
require_relative '../zabbix_credentials'

SCHEDULER.every '5m' do

  serv = Zabby.init do
    set :server => ZabbixCredentials::SERVER
    set :user => ZabbixCredentials::USERNAME
    set :password => ZabbixCredentials::PASSWORD
    login
  end

  facts = []
  env = serv.run { Zabby::Host.get({"filter" => {}}) }
  pas = JSON.parse(env.to_json)
  facts.push({label: 'Hosts', value: pas.count})

  env = serv.run { Zabby::Maintenance.get({"filter" => {}}) }
  pas = JSON.parse(env.to_json)
  facts.push({label: 'Maintenances', value: pas.count})

  env = serv.run { Zabby::Application.get({"filter" => {}}) }
  pas = JSON.parse(env.to_json)
  facts.push({label: 'Applications', value: pas.count})

  env = serv.run { Zabby::Trigger.get({"filter" => {}}) }
  pas = JSON.parse(env.to_json)
  facts.push({label: 'Trigger', value: pas.count})

  env = serv.run { Zabby::Template.get({"filter" => {}}) }
  pas = JSON.parse(env.to_json)
  facts.push({label: 'Templates', value: pas.count})

  send_event("zabbix_info", {items: facts})

end