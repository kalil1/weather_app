class AddDescriptionAndCachedToForecasts < ActiveRecord::Migration[6.1]
  def change
    add_column :forecasts, :description, :string
    add_column :forecasts, :cached, :boolean
  end
end
