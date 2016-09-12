require 'active_support/core_ext/object/to_query'

# Helper class which lists and groups trigger entries
class TriggerList
  def initialize(states, url)
    @url = url.gsub(/\/api_jsonrpc.php/,'')
    @prios = {}
    states.each { |key, value| @prios[key] = value.name }
    reset!
  end

  def reset!
    @list = []
    @groups = Hash.new(0)
    @group_meta = {}
    @group_hosts = Hash.new  { |h, k| h[k] = [] }
  end

  def push(obj)
    push_to_list(obj)
    push_to_groups(obj)
  end

  def push_to_list(obj)
    h = {
      host: obj['hosts'][0]['name'],
      priority_code: obj['priority'].to_i,
      priority: @prios[obj['priority'].to_i],
      description: obj['description'],
      lastchange: Time.at(obj['lastchange'].to_i).to_datetime.strftime('%F %R'),
      timestamp: obj['lastchange'].to_i
    }
    @list.push(h)
  end

  def push_to_groups(obj)
    key = "#{obj['priority']}_#{obj['description'].hash}"
    @groups[key] += 1
    @group_meta[key] = {
      description: obj['description'],
      priority_code: obj['priority'].to_i,
      priority: @prios[obj['priority'].to_i]
    }
    @group_hosts[key].push(obj['hosts'][0]['name'])
  end

  def sorted_list
    @list.sort! { |x, y| [x[:priority_code], x[:timestamp]] <=> [y[:priority_code], y[:timestamp]] }
    @list.reverse
  end

  def sorted_groups
    groups = []
    @groups.each do |key, value|
      h = @group_meta[key].clone
      h[:id] = key
      h[:value] = value
      h[:hosts] = @group_hosts[key].join(', ')
      params = {
        'groupid' =>0, 'hostid'=> 0, 'fullscreen' => 0, 'form_refresh' =>1, 'filter_set' => 'Filter',
        'show_severity' => h[:priority_code],
        'txt_select' => h[:description]
      }
      h[:deeplink] ="#{@url}/tr_status.php?#{params.to_query}"
      groups.push(h)
    end
    # puts groups
    groups.sort! { |x, y| [x[:priority_code], x[:value]] <=> [y[:priority_code], y[:value]] }
    groups.reverse!
  end


end
