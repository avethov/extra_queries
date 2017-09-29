class AddSubProjectToQuery< ActiveRecord::Migration
  def change
    add_column :queries, :sub_project, :boolean, default: false
  end
end