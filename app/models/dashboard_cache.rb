class DashboardCache < ApplicationRecord
  # Validations
  validates :cache_key, presence: true, uniqueness: true
  validates :cache_type, presence: true

  # Scopes
  scope :expired, -> { where("expires_at < ?", Time.current) }
  scope :valid, -> { where("expires_at >= ? OR expires_at IS NULL", Time.current) }
  scope :by_type, ->(type) { where(cache_type: type) }
  scope :for_entity, ->(type, id) { where(entity_type: type, entity_id: id) }

  # Class methods
  def self.fetch(key, cache_type: "general", expires_in: 5.minutes, entity: nil)
    cache = find_by(cache_key: key)
    
    # Return cached data if valid
    if cache && !cache.expired?
      return cache.cache_data
    end
    
    # If block given, generate new data
    if block_given?
      data = yield
      
      # Store in cache
      cache ||= new(cache_key: key)
      cache.cache_type = cache_type
      cache.cache_data = data
      cache.expires_at = expires_in.from_now if expires_in
      
      if entity
        cache.entity_type = entity.class.name
        cache.entity_id = entity.id
      end
      
      cache.save!
      data
    else
      nil
    end
  end

  def self.clear_expired!
    expired.destroy_all
  end

  def self.clear_by_type(cache_type)
    by_type(cache_type).destroy_all
  end

  def self.clear_for_entity(entity)
    for_entity(entity.class.name, entity.id).destroy_all
  end

  def self.clear_all!
    destroy_all
  end

  # Instance methods
  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def valid?
    !expired?
  end

  def time_to_expiry
    return nil unless expires_at
    return 0 if expired?
    
    (expires_at - Time.current).to_i
  end

  def refresh!(data = nil)
    if block_given?
      self.cache_data = yield
    elsif data
      self.cache_data = data
    end
    
    self.expires_at = 5.minutes.from_now if expires_at.present?
    save!
  end

  def invalidate!
    self.expires_at = 1.second.ago
    save!
  end
end