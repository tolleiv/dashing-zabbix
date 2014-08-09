class Dashing.ZabbixTriggeredHosts extends Dashing.Widget

  onData: (data) ->
    $(@node).find('.empty').remove()
    if data.items.length == 0
      $(@node).find('ul').append('<li class="empty">No triggers reported</li>')
