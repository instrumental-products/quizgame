class CreateDashboardCaches < ActiveRecord::Migration[8.0]
  def change
    create_table :dashboard_caches do |t|
      t.string :cache_key, null: false
      t.string :cache_type, null: false
      t.json :cache_data
      t.datetime :expires_at
      t.integer :entity_id
      t.string :entity_type

      t.timestamps
    end

    # Indexes for efficient cache lookups
    add_index :dashboard_caches, :cache_key, unique: true
    add_index :dashboard_caches, :cache_type
    add_index :dashboard_caches, [:entity_type, :entity_id]
    add_index :dashboard_caches, :expires_at
  end
end
