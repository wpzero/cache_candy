require "cache_candy/version"

module CacheCandy
  include CandyBox

  write_candy_config do
    cache_keys []
  end

  def self.included(base)
    base.after_save :flush_cache, if: :changed
    base.after_destroy :flush_cache
  end

  def flush_cache
    candy_config.cache_keys.each do |cache_key|
      Rails.cache.delete get_cache_key(cache_key)
    end
  end

  def get_cache_key(cache_key)
    partition_id = cache_key[/%\{(\w*)\}/, 1]
    if partition_id.present?
      cache_key % { partition_id.to_sym => send(partition_id) }
    else
      cache_key
    end
  end
end
