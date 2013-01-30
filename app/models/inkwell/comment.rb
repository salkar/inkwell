module Inkwell
  class Comment < ActiveRecord::Base
    attr_accessible :body, :post_id, :parent_id
    attr_accessor :is_reblogged
    attr_accessor :is_favorited
    attr_accessor :item_id_in_line
    attr_accessor :is_reblog_in_blogline
    attr_accessor :from_sources_in_timeline

    validates :"#{::Inkwell::Engine::config.post_table.to_s.singularize}_id", :presence => true
    validates :"#{::Inkwell::Engine::config.user_table.to_s.singularize}_id", :presence => true
    validates :body, :presence => true

    after_create :processing_a_comment
    before_destroy :destroy_comment_processing

    belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize
    belongs_to ::Inkwell::Engine::config.post_table.to_s.singularize

    def commentline(options = {})
      last_shown_comment_id = options[:last_shown_comment_id] || options['last_shown_comment_id']
      limit = options[:limit] || options['limit'] || 10
      for_user = options[:for_user] || options['for_user']

      if for_user
        user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
        raise "for_user param should be a #{user_class.to_s} but it is #{for_user.class.to_s}" unless for_user.class == user_class
      end
      users_ids_who_comment_it = ActiveSupport::JSON.decode self.users_ids_who_comment_it
      if last_shown_comment_id
        last_shown_comment_index = users_ids_who_comment_it.index{|rec| rec["comment_id"] == last_shown_comment_id}
        users_ids_who_comment_it = users_ids_who_comment_it[0..last_shown_comment_index-1]
      end
      result_comments_info = users_ids_who_comment_it.last(limit)
      result = []
      result_comments_info.each do |comment_info|
        comment = ::Inkwell::Comment.find comment_info["comment_id"]
        if for_user
            comment.is_reblogged = for_user.reblog? comment
            comment.is_favorited = for_user.favorite? comment
        end
        result << comment
      end
      result
    end

    def comment_count
      users_ids_who_comment_it = ActiveSupport::JSON.decode self.users_ids_who_comment_it
      users_ids_who_comment_it.size
    end

    def favorite_count
      users_ids_who_favorite_it = ActiveSupport::JSON.decode self.users_ids_who_favorite_it
      users_ids_who_favorite_it.size
    end

    def reblog_count
      users_ids_who_reblog_it = ActiveSupport::JSON.decode self.users_ids_who_reblog_it
      users_ids_who_reblog_it.size
    end

    protected

    def remove_info_from_upper_comments(comments_info)
      return unless self.parent_id
      parent_comment = ::Inkwell::Comment.find self.parent_id
      raise "There is no comment with id = #{self.parent_id}" unless parent_comment
      users_ids_who_comment_it = ActiveSupport::JSON.decode parent_comment.users_ids_who_comment_it
      users_ids_who_comment_it -= comments_info
      parent_comment.users_ids_who_comment_it = ActiveSupport::JSON.encode users_ids_who_comment_it
      parent_comment.save
      parent_comment.remove_info_from_upper_comments(comments_info)
    end

    private

    def destroy_comment_processing
      child_comments = ActiveSupport::JSON.decode self.users_ids_who_comment_it
      child_comments_ids_to_deleted = []
      child_comments.each do |comment|
        child_comments_ids_to_deleted << comment['comment_id']
      end
      ::Inkwell::Comment.delete child_comments_ids_to_deleted

      comment_with_child_comments_ids_to_deleted = child_comments_ids_to_deleted << self.id
      ::Inkwell::TimelineItem.delete_all :item_id => comment_with_child_comments_ids_to_deleted, :is_comment => true
      ::Inkwell::FavoriteItem.delete_all :item_id => comment_with_child_comments_ids_to_deleted, :is_comment => true
      ::Inkwell::BlogItem.delete_all :item_id => comment_with_child_comments_ids_to_deleted, :is_comment => true

      user_id = self.send("#{::Inkwell::Engine::config.user_table.to_s.singularize}_id")
      comment_with_child_comments_info = child_comments << Hash['user_id' => user_id, 'comment_id' => self.id]
      remove_info_from_upper_comments comment_with_child_comments_info

      post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
      post_id_attr = "#{::Inkwell::Engine::config.post_table.to_s.singularize}_id"
      parent_post = post_class.find self.send post_id_attr
      users_ids_who_comment_it = ActiveSupport::JSON.decode parent_post.users_ids_who_comment_it
      users_ids_who_comment_it -= comment_with_child_comments_info
      parent_post.users_ids_who_comment_it = ActiveSupport::JSON.encode users_ids_who_comment_it
      parent_post.save
    end

    def processing_a_comment
      self.users_ids_who_favorite_it = "[]"
      self.users_ids_who_comment_it = "[]"
      self.users_ids_who_reblog_it = "[]"
      self.save

      post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
      post_id_attr = "#{::Inkwell::Engine::config.post_table.to_s.singularize}_id"
      parent_post = post_class.find self.send post_id_attr
      user_id = self.send "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      users_ids_who_comment_it = ActiveSupport::JSON.decode parent_post.users_ids_who_comment_it
      users_ids_who_comment_it << Hash['user_id' => user_id, 'comment_id' => self.id]
      parent_post.users_ids_who_comment_it = ActiveSupport::JSON.encode users_ids_who_comment_it
      parent_post.save

      add_user_info_to_upper_comments
    end

    def add_user_info_to_upper_comments
      if self.parent_id
        parent_comment = ::Inkwell::Comment.find self.parent_id
        raise "Comment with id #{comment.parent_id} is not found" unless parent_comment
        parent_upper_comments_tree = ActiveSupport::JSON.decode parent_comment.upper_comments_tree
        self_upper_comments_tree = parent_upper_comments_tree << parent_comment.id
        self.upper_comments_tree = ActiveSupport::JSON.encode self_upper_comments_tree

        user_id = self.send "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"

        self_upper_comments_tree.each do |comment_id|
          comment = ::Inkwell::Comment.find comment_id
          users_ids_who_comment_it = ActiveSupport::JSON.decode comment.users_ids_who_comment_it
          users_ids_who_comment_it << Hash['user_id' => user_id, 'comment_id' => self.id]
          comment.users_ids_who_comment_it = ActiveSupport::JSON.encode users_ids_who_comment_it
          comment.save
        end
      else
        self.upper_comments_tree = ActiveSupport::JSON.encode []
      end

      self.save
    end
  end
end
