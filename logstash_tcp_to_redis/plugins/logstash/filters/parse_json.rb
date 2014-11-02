require "logstash/filters/base"
require "logstash/namespace"

class LogStash::Filters::ParseJson < LogStash::Filters::Base

  config_name "parse_json"

  milestone 1

  public
  def register
    require "open-uri"
    require "active_support/core_ext/hash/deep_merge"
  end

  public
  def filter(event)
    return unless filter?(event)

    begin
      msg  = event["message"]
      dest = event.to_hash
      json = JSON.parse(msg)
      dest.merge!(json)
    rescue => e
      event.tag("_jsonparsefailure")
      @logger.warn("Trouble parsing json", :event => event, :exception => e, :backtrace => e.backtrace)
      return
    end
    filter_matched(event)
  end

  private
  def to_deep_hash(k, v)
    ks = k.to_s.split('.')
    length = ks.length
    h={ks.last => v}
    return h if ks.length < 2
    (length - 1).times do |i|
      i = length - 2 - i
      key = h.keys.first
      value = h.delete(key)
      h[ks[i]] = {key => value}
    end
    h
  end

  def merge_hash(params)
    new_params = {}
    params.each do |k, v|
      h = to_deep_hash(k, v)
      new_params.deep_merge!(h)
    end
    new_params
  end

  def one_level_hash(params)
    new_params = {}
    params.each do |k,v| 
      new_params[k] = v.to_s
    end
    new_params
  end
end
