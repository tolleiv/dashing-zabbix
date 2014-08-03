class Dashing.ZabbixStatus extends Dashing.Widget
 @accessor 'current', Dashing.AnimatedValue

 onData: (data) ->
  if data.status
   # clear existing "status-*" classes
   $(@get('node')).attr 'class', (i,c) ->
      c.replace /\bzabbix-\S+/g, ''
   # add new class
   $(@get('node')).addClass "zabbix-#{data.status}"