module Inkwell
  module ActsAsInkwellUser
    module Base
      def self.included(klass)
        klass.class_eval do
          extend Config
        end
      end
    end

    module Config
      def acts_as_inkwell_user
        has_many :comments, :class_name => 'Inkwell::Comment'
        has_many :following_relations, :class_name => 'Inkwell::Following', :foreign_key => :follower_id
        has_many :followings, :through => :following_relations, :class_name => ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
        has_many :follower_relations, :class_name => 'Inkwell::Following', :foreign_key => :followed_id
        has_many :followers, :through => :follower_relations, :class_name => ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
        if ::Inkwell::Engine::config.respond_to?('community_table')
          has_many :communities_users, :class_name => 'Inkwell::CommunityUser'
          has_many :communities, -> {where "inkwell_community_users.active" => true}, :through => :communities_users, :class_name => ::Inkwell::Engine::config.community_table.to_s.singularize.capitalize
        end
        before_destroy :destroy_processing
        include ::Inkwell::ActsAsInkwellUser::InstanceMethods
      end
    end

    module InstanceMethods
      require_relative '../common/base.rb'
      include ::Inkwell::Constants
      include ::Inkwell::Common

      def blogline(options = {})
        options.symbolize_keys!
        last_shown_obj_id = options[:last_shown_obj_id]
        limit = options[:limit] || 10
        for_user = options[:for_user]
        category = options[:category]

        if category
          child_categories = ActiveSupport::JSON.decode category.child_ids
          category_ids = [category.id] + child_categories
          if last_shown_obj_id
            blog_items_categories = ::Inkwell::BlogItemCategory.where(:category_id => category_ids).where("blog_item_created_at < ?", Inkwell::BlogItem.find(last_shown_obj_id).created_at).order("blog_item_created_at DESC").limit(limit)
          else
            blog_items_categories = ::Inkwell::BlogItemCategory.where(:category_id => category_ids).order("blog_item_created_at DESC").limit(limit)
          end

          blog_items_ids = []
          blog_items_categories.each do |record|
            blog_items_ids << record.blog_item_id
          end
          blog_items = ::Inkwell::BlogItem.where(:id => blog_items_ids, :owner_id => self.id, :owner_type => OwnerTypes::USER).order("created_at DESC")
        else
          if last_shown_obj_id
            blog_items = ::Inkwell::BlogItem.where(:owner_id => self.id, :owner_type => OwnerTypes::USER).where("created_at < ?", Inkwell::BlogItem.find(last_shown_obj_id).created_at).order("created_at DESC").limit(limit)
          else
            blog_items = ::Inkwell::BlogItem.where(:owner_id => self.id, :owner_type => OwnerTypes::USER).order("created_at DESC").limit(limit)
          end
        end

        result = []
        blog_items.each do |item|
          if item.item_type == ItemTypes::COMMENT
            blog_obj = ::Inkwell::Comment.find item.item_id
          else
            blog_obj = post_class.find item.item_id
          end

          blog_obj.item_id_in_line = item.id
          blog_obj.is_reblog_in_blogline = item.is_reblog

          if for_user
            blog_obj.is_reblogged = for_user.reblog? blog_obj
            blog_obj.is_favorited = for_user.favorite? blog_obj
          end

          result << blog_obj
        end
        result
      end

      def create_comment(options = {})
        options.symbolize_keys!
        raise "for_object should be passed" unless options[:for_object]
        raise "comment body should be passed" unless options[:body]
        for_object = options[:for_object]
        options[:topmost_obj_id] = for_object.id
        options[:topmost_obj_type] = get_item_type for_object
        options.delete :for_object
        self.comments.create options
      end

      def communities_row
        user_id = "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
        community_id = "#{::Inkwell::Engine::config.community_table.to_s.singularize}_id"

        relations = ::Inkwell::CommunityUser.where user_id => self.id
        result = []
        relations.each do |relation|
          result << relation.send(community_id)
        end
        result
      end

      def favorite(obj)
        return if self.favorite? obj

        FavoriteItem.create :item_id => obj.id, :owner_id => self.id, :owner_type => OwnerTypes::USER, :item_type => get_item_type(obj)

        users_ids_who_favorite_it = ActiveSupport::JSON.decode obj.users_ids_who_favorite_it
        users_ids_who_favorite_it << self.id
        obj.users_ids_who_favorite_it = ActiveSupport::JSON.encode users_ids_who_favorite_it
        obj.save
      end

      def favorite?(obj)
        FavoriteItem.where(:item_id => obj.id, :item_type => get_item_type(obj), :owner_id => self.id, :owner_type => OwnerTypes::USER).first ? true : false
      end

      def unfavorite(obj)
        return unless self.favorite? obj

        ::Inkwell::FavoriteItem.where(:item_id => obj.id, :item_type => get_item_type(obj), :owner_id => self.id, :owner_type => OwnerTypes::USER).destroy_all

        users_ids_who_favorite_it = ActiveSupport::JSON.decode obj.users_ids_who_favorite_it
        users_ids_who_favorite_it.delete self.id
        obj.users_ids_who_favorite_it = ActiveSupport::JSON.encode users_ids_who_favorite_it
        obj.save
      end

      def favoriteline(options = {})
        options.symbolize_keys!
        last_shown_obj_id = options[:last_shown_obj_id]
        limit = options[:limit] || 10
        for_user = options[:for_user]

        if last_shown_obj_id
          favorites = ::Inkwell::FavoriteItem.where(:owner_id => self.id, :owner_type => OwnerTypes::USER).where("created_at < ?", Inkwell::FavoriteItem.find(last_shown_obj_id).created_at).order("created_at DESC").limit(limit)
        else
          favorites = ::Inkwell::FavoriteItem.where(:owner_id => self.id, :owner_type => OwnerTypes::USER).order("created_at DESC").limit(limit)
        end

        post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
        result = []
        favorites.each do |item|
          if item.item_type == ItemTypes::COMMENT
            favorited_obj = ::Inkwell::Comment.find item.item_id
          else
            favorited_obj = post_class.find item.item_id
          end

          favorited_obj.item_id_in_line = item.id

          if for_user
            favorited_obj.is_reblogged = for_user.reblog? favorited_obj
            favorited_obj.is_favorited = for_user.favorite? favorited_obj
          end

          result << favorited_obj
        end
        result
      end

      def follow(user)
        raise "user tries to follow already followed user" if self.follow? user
        raise "user tries to follow himself." if self == user

        ::Inkwell::Following.create :follower_id => self.id, :followed_id => user.id

        self.following_count += 1
        self.save

        user.follower_count += 1
        user.save

        post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
        user_id_attr = "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
        ::Inkwell::BlogItem.where(:owner_id => user.id, :owner_type => OwnerTypes::USER).order("created_at DESC").limit(10).each do |blog_item|
          if blog_item.is_reblog
            item_class = blog_item.item_type == ItemTypes::COMMENT ? ::Inkwell::Comment : post_class
            next if item_class.find(blog_item.item_id).send(user_id_attr) == self.id
          end

          item = TimelineItem.where(:item_id => blog_item.item_id, :owner_id => self.id, :owner_type => OwnerTypes::USER, :item_type => blog_item.item_type).first
          if item
            item.has_many_sources = true unless item.has_many_sources
            sources = ActiveSupport::JSON.decode item.from_source
            if blog_item.is_reblog
              sources << Hash['user_id' => user.id, 'type' => 'reblog']
            else
              sources << Hash['user_id' => user.id, 'type' => 'following']
            end
            item.from_source = ActiveSupport::JSON.encode sources
            item.save
          else
            sources = []
            if blog_item.is_reblog
              sources << Hash['user_id' => user.id, 'type' => 'reblog']
            else
              sources << Hash['user_id' => user.id, 'type' => 'following']
            end
            ::Inkwell::TimelineItem.create :item_id => blog_item.item_id, :item_type => blog_item.item_type, :owner_id => self.id, :owner_type => OwnerTypes::USER,
                                           :from_source => ActiveSupport::JSON.encode(sources), :created_at => blog_item.created_at
          end
        end
      end

      def unfollow(user)
        raise "user tries to unfollow not followed user" unless self.follow? user
        raise "user tries to unfollow himself." if self == user

        ::Inkwell::Following.delete_all :follower_id => self.id, :followed_id => user.id

        self.following_count -= 1
        self.save

        user.follower_count -= 1
        user.save

        timeline_items = ::Inkwell::TimelineItem.where(:owner_id => self.id, :owner_type => OwnerTypes::USER).where "from_source like '%{\"user_id\":#{user.id}%'"
        timeline_items.delete_all :has_many_sources => false
        timeline_items.each do |item|
          from_source = ActiveSupport::JSON.decode item.from_source
          from_source.delete_if { |rec| rec['user_id'] == user.id }
          item.from_source = ActiveSupport::JSON.encode from_source
          item.has_many_sources = false if from_source.size < 2
          item.save
        end
      end

      def follow?(user)
        ::Inkwell::Following.exists? :follower_id => self.id, :followed_id => user.id
      end

      def followers_row
        records = ::Inkwell::Following.where :followed_id => self.id
        result = []
        records.each do |rec|
          result << rec.follower_id
        end
        result
      end

      def followings_row
        records = ::Inkwell::Following.where :follower_id => self.id
        result = []
        records.each do |rec|
          result << rec.followed_id
        end
        result
      end

      def reblog(obj)
        return if self.reblog? obj
        raise "User tries to reblog his post." if self.id == obj.user_id

        item_type = get_item_type(obj)

        user_id_attr = "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
        BlogItem.create :item_id => obj.id, :is_reblog => true, :owner_id => self.id, :owner_type => OwnerTypes::USER, :item_type => item_type

        users_ids_who_reblog_it = ActiveSupport::JSON.decode obj.users_ids_who_reblog_it
        users_ids_who_reblog_it << self.id
        obj.users_ids_who_reblog_it = ActiveSupport::JSON.encode users_ids_who_reblog_it
        obj.save

        self.followers_row.each do |user_id|
          next if obj.send(user_id_attr) == user_id
          item = TimelineItem.where(:item_id => obj.id, :owner_id => user_id, :owner_type => OwnerTypes::USER, :item_type => item_type).first
          if item
            item.has_many_sources = true unless item.has_many_sources
            sources = ActiveSupport::JSON.decode item.from_source
            sources << Hash['user_id' => self.id, 'type' => 'reblog']
            item.from_source = ActiveSupport::JSON.encode sources
            item.save
          else
            encode_sources = ActiveSupport::JSON.encode [Hash['user_id' => self.id, 'type' => 'reblog']]
            TimelineItem.create :item_id => obj.id, :created_at => obj.created_at, :owner_id => user_id, :owner_type => OwnerTypes::USER, :from_source => encode_sources, :item_type => item_type
          end
        end
      end

      def reblog?(obj)
        BlogItem.exists? :item_id => obj.id, :owner_id => self.id, :owner_type => OwnerTypes::USER, :is_reblog => true, :item_type => get_item_type(obj)
      end

      def unreblog(obj)
        return unless self.reblog? obj
        raise "User tries to unreblog his post." if self.id == obj.user_id

        item_type = get_item_type(obj)

        users_ids_who_reblog_it = ActiveSupport::JSON.decode obj.users_ids_who_reblog_it
        users_ids_who_reblog_it.delete self.id
        obj.users_ids_who_reblog_it = ActiveSupport::JSON.encode users_ids_who_reblog_it
        obj.save

        ::Inkwell::BlogItem.delete_all :owner_id => self.id, :owner_type => OwnerTypes::USER, :item_id => obj.id, :is_reblog => true, :item_type => item_type

        TimelineItem.delete_all :owner_id => self.followers_row, :owner_type => OwnerTypes::USER, :has_many_sources => false, :item_id => obj.id, :item_type => item_type
        TimelineItem.where(:owner_id => self.followers_row, :owner_type => OwnerTypes::USER, :item_id => obj.id, :item_type => item_type).each do |item|
            sources = ActiveSupport::JSON.decode item.from_source
            sources.delete Hash['user_id' => self.id, 'type' => 'reblog']
            item.has_many_sources = false if sources.size < 2
            item.from_source = ActiveSupport::JSON.encode sources
            item.save
        end
      end

      def timeline(options = {})
        options.symbolize_keys!
        last_shown_obj_id = options[:last_shown_obj_id]
        limit = options[:limit] || 10
        for_user = options[:for_user]

        if last_shown_obj_id
          timeline_items = ::Inkwell::TimelineItem.where(:owner_id => self.id, :owner_type => OwnerTypes::USER).where("created_at < ?", Inkwell::TimelineItem.find(last_shown_obj_id).created_at).order("created_at DESC").limit(limit)
        else
          timeline_items = ::Inkwell::TimelineItem.where(:owner_id => self.id, :owner_type => OwnerTypes::USER).order("created_at DESC").limit(limit)
        end

        post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
        result = []
        timeline_items.each do |item|
          if item.item_type == ItemTypes::COMMENT
            timeline_obj = ::Inkwell::Comment.find item.item_id
          else
            timeline_obj = post_class.find item.item_id
          end

          timeline_obj.item_id_in_line = item.id
          timeline_obj.from_sources_in_timeline = item.from_source

          if for_user
            timeline_obj.is_reblogged = for_user.reblog? timeline_obj
            timeline_obj.is_favorited = for_user.favorite? timeline_obj
          end

          result << timeline_obj
        end
        result
      end

      #wrappers for community methods

      def join(open_community)
        raise "it is impossible to join private community. use invitation request to do it." unless open_community.public
        open_community.add_user :user => self
      end

      def request_invitation(community)
        community.create_invitation_request(self)
      end

      def approve_invitation_request(options = {})
        options.symbolize_keys!
        community = options[:community]
        user = options[:user]
        community.accept_invitation_request :user => user, :admin => self
      end

      def reject_invitation_request(options = {})
        options.symbolize_keys!
        community = options[:community]
        user = options[:user]
        community.reject_invitation_request :user => user, :admin => self
      end

      def leave(community)
        community.remove_user :user => self
      end

      def kick(options = {})
        options.symbolize_keys!
        from_community = options[:from_community]
        user = options[:user]
        from_community.remove_user :user => user, :admin => self
      end

      def ban(options = {})
        options.symbolize_keys!
        in_community = options[:in_community]
        user = options[:user]
        in_community.ban_user :user => user, :admin => self
      end

      def unban(options = {})
        options.symbolize_keys!
        in_community = options[:in_community]
        user = options[:user]
        in_community.unban_user :user => user, :admin => self
      end

      def mute(options = {})
        options.symbolize_keys!
        in_community = options[:in_community]
        user = options[:user]
        in_community.mute_user :user => user, :admin => self
      end

      def unmute(options = {})
        options.symbolize_keys!
        in_community = options[:in_community]
        user = options[:user]
        in_community.unmute_user :user => user, :admin => self
      end

      def can_send_post_to_community?(community)
        relation = ::Inkwell::CommunityUser.where(user_id_attr => self.id, community_id_attr => community.id).first
        return false unless relation
        return false if relation.muted
        return false unless relation.user_access == CommunityAccessLevels::WRITE
        true
      end

      def send_post_to_community(options = {})
        options.symbolize_keys!
        to_community = options[:to_community]
        post = options[:post]
        raise "this user have no permissions to send post to this community" unless self.can_send_post_to_community? to_community
        to_community.add_post :post => post, :user => self
      end

      def remove_post_from_community(options = {})
        options.symbolize_keys!
        from_community = options[:from_community]
        post = options[:post]
        from_community.remove_post :post => post, :user => self
      end

      def grant_admin_permissions(options = {})
        options.symbolize_keys!
        to_user = options[:to_user]
        in_community = options[:in_community]
        in_community.add_admin :user => to_user, :admin => self
      end

      def revoke_admin_permissions(options = {})
        options.symbolize_keys!
        user = options[:user]
        in_community = options[:in_community]
        in_community.remove_admin :user => user, :admin => self
      end

      #wrappers for category methods

      def create_category(options = {})
        options.symbolize_keys!
        options[:owner_id] = self.id
        options[:owner_type] = OwnerTypes::USER
        category_class.create options
      end

      def get_categories
        category_class.get_categories_for :object => self, :type => OwnerTypes::USER
      end


      def destroy_processing
        if ::Inkwell::Engine::config.respond_to?('community_table')
          raise "there is community where this user is owner. Change their owner before destroy this user." unless community_class.where(:owner_id => self.id).empty?

          communities_relations = ::Inkwell::CommunityUser.where user_id_attr => self.id
          communities_relations.each do |relation|
            community = community_class.find relation.send(community_id_attr)
            if relation.active
              if relation.user_access == CommunityAccessLevels::WRITE
                community.writer_count -= 1
              end
              community.admin_count -= 1 if relation.is_admin
              community.muted_count -= 1 if relation.muted
              community.user_count -= 1
            else
              community.banned_count -= 1 if relation.banned
              community.invitation_count -= 1 if relation.asked_invitation
            end

            community.save
          end

          ::Inkwell::CommunityUser.delete_all user_id_attr => self.id
        end

        if ::Inkwell::Engine::config.respond_to?('category_table')
          categories = category_class.where :owner_id => self.id, :owner_type => OwnerTypes::USER
          category_ids = []
          categories.each do |category|
            category_ids << category.id
          end
          category_class.delete_all :id => category_ids
          ::Inkwell::BlogItemCategory.delete_all :category_id => category_ids
        end
      end

    end
  end
end

::ActiveRecord::Base.send :include, ::Inkwell::ActsAsInkwellUser::Base