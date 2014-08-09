require 'zabby'
require 'json'
require 'active_support/core_ext/numeric/time'
require_relative '../zabbix_credentials'

# Encapsulates the count queries
class Zabbix
  def initialize
    @serv = Zabby.init do
      set server: ZabbixCredentials::SERVER
      set user: ZabbixCredentials::USERNAME
      set password: ZabbixCredentials::PASSWORD
      login
    end
  end

  def pass(name, &block)
    count = @serv.run(&block)
    { label: name, value: count }
  end
end

SCHEDULER.every '15m' do

  z = Zabbix.new

  facts = []
  facts.push(z.pass('Hosts') { Zabby::Host.get('countOutput' => 1) })
  facts.push(z.pass('Maintenances') { Zabby::Maintenance.get('countOutput' => 1) })
  facts.push(z.pass('Events') { Zabby::Event.get('countOutput' => 1, 'hide_unknown' => 1, 'acknowledged' => 0) })
  facts.push(z.pass('Items') { Zabby::Item.get('countOutput' => 1) })
  facts.push(z.pass('Applications') { Zabby::Application.get('countOutput' => 1) })
  facts.push(z.pass('Triggers') { Zabby::Trigger.get('countOutput' => 1) })
  facts.push(z.pass('Templates') { Zabby::Template.get('countOutput' => 1) })
  send_event('zabbix_info', items: facts)

end
