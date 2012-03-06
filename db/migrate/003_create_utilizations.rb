class CreateUtilizations < ActiveRecord::Migration
  def up
    create_table :utilizations do |t|
      t.integer :id_user
      t.integer :id_application
    end
  end

  def down
    destroy_table :utilizations
  end
end
