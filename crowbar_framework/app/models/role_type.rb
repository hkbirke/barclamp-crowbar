# Copyright 2013, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class RoleType < ActiveRecord::Base

  # priority: the order this role gets applied in, system wide
  # states: node states that this role will be included in the excution list for the node
  attr_accessible :name, :states, :order, :description
  
  validates_format_of :name, :with=>/^[a-zA-Z][_\-a-zA-Z0-9]*$/, :message => I18n.t("db.lettersnumbers", :default=>"Name limited to [_a-zA-Z0-9]")
  validates_uniqueness_of :name, :case_sensitive => false, :message => I18n.t("db.notunique", :default=>"Name item must be unique")

  has_many :roles,                :dependent => :destroy, :inverse_of => :role_type

  alias_attribute :priority,      :order
  
  def self.find_private  
    self.find_or_create_by_name :name => "private", 
                                :description => I18n.t('model.role.private_role_description'),
                                :order => 1
  end
  
  def self.add(role_type, source='unknown')
    # this should become a switch as some point!
    if role_type.is_a? RoleType
      r = role_type
    elsif role_type.is_a? Role
      r = role_type.role_type
    elsif role_type.is_a? String or role_type.is_a? Symbol
      # we can make them from just a string
      desc = I18n.t 'model.role.default_create_description', :name=>source
      r = RoleType.find_or_create_by_name :name => role_type.to_s, :description => desc
    elsif role_type.is_a? Hash
      # we can make them from a hash if the creator wants to include more info
      raise "role_type.add requires attribute :name" if role_type.nil? or !role_type.has_key? :name
      r = RoleType.find_or_create_by_name role_type
    else
      raise "role_type.add cannot use #{role_type.class || 'nil'} to create from attribute: #{role_type.inspect}"
    end 
    r
  end
  
end

