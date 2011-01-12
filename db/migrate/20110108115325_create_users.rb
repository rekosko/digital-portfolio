class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :nickname
      t.string :name
      t.string :surname
      t.integer :age
      t.string :email
      t.string :www
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
