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
        attr_accessor :parent_category_id

        validates :owner_id, :presence => true
        validates :owner_type, :presence => true

        before_create :before_create_processing
        after_create :after_create_processing
        before_destroy :before_destroy_processing

        include ::Inkwell::ActsAsInkwellCategory::InstanceMethods
        extend ::Inkwell::ActsAsInkwellCategory::ClassMethods

      end
    end

    module ClassMethods
      require_relative '../common/base.rb'
      include ::Inkwell::Constants
      include ::Inkwell::Common

      def get_categories_for(options = {})
        options.symbolize_keys!
        object = options[:object]
        type = options[:type]
        result = category_class.where :owner_id => object.id, :owner_type => type
        result.each do |category|
          parent_ids = ActiveSupport::JSON.decode category.parent_ids
          category.parent_category_id = parent_ids.last
        end
        result
      end
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
        ::Inkwell::BlogItemCategory.create :blog_item_id => blog_item.id, :category_id => self.id,
                                           :blog_item_created_at => blog_item.created_at, :item_id => blog_item.item_id, :item_type => blog_item.item_type
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

      def before_create_processing
        if self.parent_category_id
          parent = category_class.find self.parent_category_id
          his_parent_ids = ActiveSupport::JSON.decode parent.parent_ids
          parent_ids = his_parent_ids + [parent.id]
          self.parent_ids = ActiveSupport::JSON.encode parent_ids
        end
      end

      def after_create_processing
        parent_ids = ActiveSupport::JSON.decode self.parent_ids
        parent_ids.each do |parent_id|
          parent = category_class.find parent_id
          his_child_ids = ActiveSupport::JSON.decode parent.child_ids
          his_child_ids << self.id
          parent.child_ids = ActiveSupport::JSON.encode his_child_ids
          parent.save
        end
      end

      def before_destroy_processing
        child_ids = ActiveSupport::JSON.decode self.child_ids
        ids_to_delete_for_parent = child_ids + [self.id]
        category_class.delete_all :id => child_ids unless child_ids.empty?

        parent_ids = ActiveSupport::JSON.decode self.parent_ids
        parent_ids.each do |parent_id|
          parent = category_class.find parent_id
          his_child_ids = ActiveSupport::JSON.decode parent.child_ids
          his_child_ids -= ids_to_delete_for_parent
          parent.child_ids = ActiveSupport::JSON.encode his_child_ids
          parent.save
        end

        ::Inkwell::BlogItemCategory.delete_all :category_id => ids_to_delete_for_parent

      end
    end
  end
end

::ActiveRecord::Base.send :include, ::Inkwell::ActsAsInkwellCategory::Base
