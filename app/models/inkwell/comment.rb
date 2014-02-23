module Inkwell
  class Comment < ActiveRecord::Base
    require_relative '../../../lib/common/base.rb'
    include ::Inkwell::Constants
    include ::Inkwell::Common

    attr_accessor :is_reblogged
    attr_accessor :is_favorited
    attr_accessor :item_id_in_line
    attr_accessor :is_reblog_in_blogline
    attr_accessor :from_sources_in_timeline

    validates :"#{::Inkwell::Engine::config.user_table.to_s.singularize}_id", :presence => true
    validates :body, :presence => true

    after_create :processing_a_comment
    before_destroy :destroy_comment_processing

    belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize.to_sym
    belongs_to :commentable, polymorphic: true

    acts_as_nested_set :order_column => :created_at

    def commentline(options = {})
      options.symbolize_keys!
      last_shown_comment_id = options[:last_shown_comment_id]
      limit = options[:limit] || 10
      for_user = options[:for_user]

      if for_user
        user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
        raise "for_user param should be a #{user_class.to_s} but it is #{for_user.class.to_s}" unless for_user.class == user_class
      end

      result = self.descendants
      result = result.where('created_at < ?', Inkwell::Comment.find(last_shown_comment_id).created_at) if last_shown_comment_id
      result = result.includes(:user).last(limit)

      result.each do |comment|
        if for_user
            comment.is_reblogged = for_user.reblog? comment
            comment.is_favorited = for_user.favorite? comment
        end
      end
      result
    end

    def comments_count
      self.descendants.size
    end

    def favorites_count
      ::Inkwell::FavoriteItem.where(:item_id => self.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT).size
    end

    def reblogs_count
      ::Inkwell::BlogItem.where(:item_id => self.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :is_reblog => true).size
    end

    alias_method :comment_count, :comments_count
    alias_method :favorite_count, :favorites_count
    alias_method :reblog_count, :reblogs_count

    private

    def destroy_comment_processing
      child_comments_ids_to_delete = self.descendants.collect{|comment| comment.id}
      child_comments = self.descendants.collect{|comment| {'user_id' => comment.send("#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"), 'comment_id' => comment.id}}
      ::Inkwell::Comment.delete child_comments_ids_to_delete

      comments_ids_to_delete = child_comments_ids_to_delete << self.id
      ::Inkwell::TimelineItem.delete_all :item_id => comments_ids_to_delete, :item_type => ItemTypes::COMMENT
      ::Inkwell::FavoriteItem.delete_all :item_id => comments_ids_to_delete, :item_type => ItemTypes::COMMENT
      blog_items_ids = ::Inkwell::BlogItem.where(:item_id => comments_ids_to_delete, :item_type => ItemTypes::COMMENT).pluck(:id)
      ::Inkwell::BlogItem.delete_all :id => blog_items_ids

      user_id = self.send user_id_attr
      comments_info_to_delete = child_comments << Hash['user_id' => user_id, 'comment_id' => self.id]

      parent_obj = self.commentable
      users_ids_who_comment_it = ActiveSupport::JSON.decode parent_obj.users_ids_who_comment_it
      users_ids_who_comment_it -= comments_info_to_delete
      parent_obj.users_ids_who_comment_it = ActiveSupport::JSON.encode users_ids_who_comment_it
      parent_obj.save

      if ::Inkwell::Engine::config.respond_to?('category_table')
        ::Inkwell::BlogItemCategory.delete_all :blog_item_id => blog_items_ids
      end
    end

    def processing_a_comment
      parent_obj = self.commentable
      user_id = self.send "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      users_ids_who_comment_it = ActiveSupport::JSON.decode parent_obj.users_ids_who_comment_it
      users_ids_who_comment_it << Hash['user_id' => user_id, 'comment_id' => self.id]
      parent_obj.users_ids_who_comment_it = ActiveSupport::JSON.encode users_ids_who_comment_it
      parent_obj.save
    end
  end
end
