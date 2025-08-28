class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Ransack needs attributes explicitly allowlisted as searchable
  def self.ransackable_attributes(auth_object = nil)
    column_names
  end
end
