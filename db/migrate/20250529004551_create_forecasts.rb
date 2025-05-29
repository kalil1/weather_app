class CreateForecasts < ActiveRecord::Migration[6.1]
  def change
    create_table :forecasts do |t|
      t.string :zip_code, null: false
      t.string :temperature
      t.string :high
      t.string :low
      t.text :raw_data
      t.datetime :fetched_at

      t.timestamps
    end

    add_index :forecasts, :zip_code, unique: true
  end
end
