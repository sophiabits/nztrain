class AddOfficalToContest < ActiveRecord::Migration
    def change
      add_column :contests, :official, :boolean, :default => false
    end
  end
