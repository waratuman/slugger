class CreateSluggerSlugs < ActiveRecord::Migration

  def change
    create_table :slugs do |t|
      t.string   :model_type, :null => false
      t.integer  :model_id,   :null => false
      t.string   :slug,       :null => false
      t.timestamps null: false
    end

    add_index :slugs, :slug
  end
end