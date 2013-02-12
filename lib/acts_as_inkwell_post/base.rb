module Inkwell
  module ActsAsInkwellPost
    module Base
      def self.included(klass)
        klass.class_eval do
          extend Config
        end
      end
    end

    module Config
      def acts_as_inkwell_post
        attr_accessor :is_reblogged
        attr_accessor :is_favorited
        attr_accessor :item_id_in_line
        attr_accessor :is_reblog_in_blogline
        attr_accessor :from_sources_in_timeline

        after_create :processing_a_post
        before_destroy :destroy_post_processing

        has_many :comments, :class_name => 'Inkwell::Comment'
        include ::Inkwell::ActsAsInkwellPost::InstanceMethods

      end
    end

    module InstanceMethods
      require_relative '../common/base.rb'
      include ::Inkwell::Constants

      def commentline(options = {})
        options.symbolize_keys!
        last_shown_comment_id = options[:last_shown_comment_id]
        limit = options[:limit] || 10
        for_user = options[:for_user]

        if last_shown_comment_id
          comments = self.comments.where("created_at < ?", Inkwell::Comment.find(last_shown_comment_id).created_at).order("created_at DESC").limit(limit)
        else
          comments = self.comments.order("created_at DESC").limit(limit)
        end

        if for_user
          user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
          raise "for_user param should be a #{user_class.to_s} but it is #{for_user.class.to_s}" unless for_user.class == user_class
          comments.each do |comment|
            comment.is_reblogged = for_user.reblog? comment
            comment.is_favorited = for_user.favorite? comment
          end
        end

        comments.reverse!
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

      def communities_row
        ActiveSupport::JSON.decode self.communities_ids
      end

      private

      def processing_a_post
        user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
        user_id_attr = "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
        user = user_class.find self.send(user_id_attr)
        ::Inkwell::BlogItem.create :item_id => self.id, :is_reblog => false, :owner_id => self.send(user_id_attr), :is_owner_user => true, :item_type => ItemTypes::POST
        user.followers_row.each do |user_id|
          encode_sources = [ Hash['user_id' => user.id, 'type' => 'following'] ]
          ::Inkwell::TimelineItem.create :item_id => self.id, user_id_attr => user_id, :item_type => ItemTypes::POST,
                              :from_source => ActiveSupport::JSON.encode(encode_sources)
        end
      end

      def destroy_post_processing
        ::Inkwell::TimelineItem.delete_all :item_id => self.id, :item_type => ItemTypes::POST
        ::Inkwell::FavoriteItem.delete_all :item_id => self.id, :item_type => ItemTypes::POST
        ::Inkwell::BlogItem.delete_all :item_id => self.id, :item_type => ItemTypes::POST
        comments = self.comments
        comments.each do |comment|
          ::Inkwell::TimelineItem.delete_all :item_id => comment.id, :item_type => ItemTypes::COMMENT
          ::Inkwell::FavoriteItem.delete_all :item_id => comment.id, :item_type => ItemTypes::COMMENT
          ::Inkwell::BlogItem.delete_all :item_id => comment.id, :item_type => ItemTypes::COMMENT
          ::Inkwell::Comment.delete comment
        end
      end
    end
  end
end

::ActiveRecord::Base.send :include, ::Inkwell::ActsAsInkwellPost::Base