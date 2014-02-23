module Inkwell
  module ActsAsInkwellCategory
    module Base
      def self.included(klass)
        klass.class_eval do
          extend Config
        end
      end
    end

    module Config
      def acts_as_inkwell_category
        alias_attribute :parent_category_id, :parent_id
        deprecate parent_category_id: 'parent_category_id deprecated. Will be removed. Use parent_id.'
        validates_presence_of :categoryable
        before_destroy :before_destroy_processing

        belongs_to :categoryable, polymorphic: true
        acts_as_nested_set

        include ::Inkwell::ActsAsInkwellCategory::InstanceMethods
        extend ::Inkwell::ActsAsInkwellCategory::ClassMethods

      end
    end

    module ClassMethods
      require_relative '../common/base.rb'
      include ::Inkwell::Constants
      include ::Inkwell::Common
    end

    module InstanceMethods
      require_relative '../common/base.rb'
      include ::Inkwell::Constants
      include ::Inkwell::Common

      def add_item(options = {})
        options.symbolize_keys!
        item = options[:item]
        item_type = get_item_type item
        owner = options[:owner]
        owner_type = get_owner_type owner
        blog_item = Inkwell::BlogItem.where(:owner_id => owner.id, :owner_type => owner_type, :item_id => item.id, :item_type => item_type).first
        ::Inkwell::BlogItemCategory.create :blog_item_id => blog_item.id, :category_id => self.id, :blog_item_created_at => blog_item.created_at
      end

      def remove_item(options = {})
        options.symbolize_keys!
        item = options[:item]
        item_type = get_item_type item
        owner = options[:owner]
        owner_type = get_owner_type owner
        blog_item = Inkwell::BlogItem.where(:owner_id => owner.id, :owner_type => owner_type, :item_id => item.id, :item_type => item_type).first
        ::Inkwell::BlogItemCategory.delete_all :blog_item_id => blog_item.id, :category_id => self.id
      end

      def before_destroy_processing
        ::Inkwell::BlogItemCategory.delete_all :category_id => self.self_and_descendants.map(&:id)
      end
    end
  end
end

::ActiveRecord::Base.send :include, ::Inkwell::ActsAsInkwellCategory::Base
