module Inkwell
  module ActsAsInkwellCommunity
    module Base
      def self.included(klass)
        klass.class_eval do
          extend Config
        end
      end
    end

    module Config
      def acts_as_inkwell_community
        validates :owner_id, :presence => true

        after_create :processing_a_community
        before_destroy :destroy_community_processing

        include ::Inkwell::ActsAsInkwellCommunity::InstanceMethods
      end
    end

    module InstanceMethods
      require_relative '../common/base.rb'
      include ::Inkwell::Constants
      include ::Inkwell::Common

      def add_user(options = {})
        options.symbolize_keys!
        user = options[:user]
        raise "this user is already in this community" if self.include_user? user
        raise "this user is banned" if self.include_banned_user? user

        users_ids = ActiveSupport::JSON.decode self.users_ids
        users_ids << user.id
        self.users_ids = ActiveSupport::JSON.encode users_ids
        if (self.default_user_access == CommunityAccessLevels::WRITE) && !(self.include_muted_user? user)
          writers_ids = ActiveSupport::JSON.decode self.writers_ids
          writers_ids << user.id
          self.writers_ids = ActiveSupport::JSON.encode writers_ids
        end
        self.save

        communities_info = ActiveSupport::JSON.decode user.communities_info
        communities_info << Hash[HashParams::COMMUNITY_ID => self.id, HashParams::ACCESS_LEVEL => self.default_user_access]
        user.communities_info = ActiveSupport::JSON.encode communities_info
        user.save

        post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
        user_id_attr = "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
        ::Inkwell::BlogItem.where(:owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY).order("created_at DESC").limit(10).each do |blog_item|
          next if post_class.find(blog_item.item_id).send(user_id_attr) == user.id

          item = ::Inkwell::TimelineItem.where(:item_id => blog_item.item_id, :item_type => blog_item.item_type, :owner_id => user.id, :owner_type => OwnerTypes::USER).first
          if item
            item.has_many_sources = true unless item.has_many_sources
            sources = ActiveSupport::JSON.decode item.from_source
            sources << Hash['community_id' => self.id]
            item.from_source = ActiveSupport::JSON.encode sources
            item.save
          else
            sources = [Hash['community_id' => self.id]]
            ::Inkwell::TimelineItem.create :item_id => blog_item.item_id, :item_type => blog_item.item_type, :owner_id => user.id, :owner_type => OwnerTypes::USER,
                                           :from_source => ActiveSupport::JSON.encode(sources), :created_at => blog_item.created_at
          end
        end
      end

      def remove_user(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        return unless self.include_user? user
        raise "admin is not admin" if admin && !self.include_admin?(admin)
        if self.include_admin? user
          raise "community owner can not be removed from his community" if self.admin_level_of(user) == 0
          raise "admin has no permissions to delete this user from community" if (self.admin_level_of(user) <= self.admin_level_of(admin)) && (user != admin)
        end

        users_ids = ActiveSupport::JSON.decode self.users_ids
        users_ids.delete user.id
        self.users_ids = ActiveSupport::JSON.encode users_ids

        writers_ids = ActiveSupport::JSON.decode self.writers_ids
        writers_ids.delete user.id
        self.writers_ids = ActiveSupport::JSON.encode writers_ids

        admins_info = ActiveSupport::JSON.decode self.admins_info
        admins_info.delete_if{|item| item['admin_id'] == user.id}
        self.admins_info = ActiveSupport::JSON.encode admins_info

        self.save

        communities_info = ActiveSupport::JSON.decode user.communities_info
        communities_info.delete_if {|item| item[HashParams::COMMUNITY_ID] == self.id}
        user.communities_info = ActiveSupport::JSON.encode communities_info
        user.save

        timeline_items = ::Inkwell::TimelineItem.where(:owner_id => user.id, :owner_type => OwnerTypes::USER).where "from_source like '%{\"community_id\":#{self.id}%'"
        timeline_items.delete_all :has_many_sources => false
        timeline_items.each do |item|
          from_source = ActiveSupport::JSON.decode item.from_source
          from_source.delete_if { |rec| rec['community_id'] == self.id }
          item.from_source = ActiveSupport::JSON.encode from_source
          item.has_many_sources = false if from_source.size < 2
          item.save
        end
      end

      def include_user?(user)
        check_user user
        communities_info = ActiveSupport::JSON.decode user.communities_info
        (communities_info.index{|item| item[HashParams::COMMUNITY_ID] == self.id}) ? true : false
      end

      def mute_user(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        raise "user should be passed in params" unless user
        raise "admin should be passed in params" unless admin
        check_user user
        check_user admin
        raise "admin is not admin" unless self.include_admin? admin
        raise "user should be a member of this community" unless self.include_user? user
        raise "this user is already muted" if self.include_muted_user? user
        raise "it is impossible to mute yourself" if user == admin
        raise "admin has no permissions to mute this user" if (self.include_admin? user) && (admin_level_of(admin) >= admin_level_of(user))


        muted_ids = ActiveSupport::JSON.decode self.muted_ids
        muted_ids << user.id
        self.muted_ids = ActiveSupport::JSON.encode muted_ids
        self.save
      end

      def unmute_user(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        raise "user should be passed in params" unless user
        raise "admin should be passed in params" unless admin
        check_user user
        check_user admin
        raise "admin is not admin" unless self.include_admin? admin
        raise "user should be a member of this community" unless self.include_user? user
        raise "this user is not muted" unless self.include_muted_user? user
        raise "admin has no permissions to unmute this user" if (self.include_admin? user) && (admin_level_of(admin) >= admin_level_of(user))

        muted_ids = ActiveSupport::JSON.decode self.muted_ids
        muted_ids.delete user.id
        self.muted_ids = ActiveSupport::JSON.encode muted_ids
        self.save
      end

      def include_muted_user?(user)
        check_user user
        muted_ids = ActiveSupport::JSON.decode self.muted_ids
        muted_ids.include? user.id
      end

      def include_banned_user?(user)
        check_user user
        banned_ids = ActiveSupport::JSON.decode self.banned_ids
        banned_ids.include? user.id
      end

      def add_admin(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        raise "user should be passed in params" unless user
        raise "admin should be passed in params" unless admin
        check_user user
        check_user admin
        raise "user is already admin" if self.include_admin?(user)
        raise "admin is not admin" unless self.include_admin?(admin)
        raise "user should be a member of this community" unless self.include_user?(user)

        admin_level_granted_for_user = admin_level_of(admin) + 1

        admins_info = ActiveSupport::JSON.decode self.admins_info
        admins_info << Hash['admin_id' => user.id, 'admin_level' => admin_level_granted_for_user]
        self.admins_info = ActiveSupport::JSON.encode admins_info
        self.save
      end

      def remove_admin(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        raise "user should be passed in params" unless user
        raise "admin should be passed in params" unless admin
        raise "user is not admin" unless self.include_admin?(user)
        raise "admin is not admin" unless self.include_admin?(admin)
        raise "admin has no permissions to delete this user from admins" if (admin_level_of(admin) >= admin_level_of(user)) && (user != admin)
        raise "community owner can not be removed from admins" if admin_level_of(user) == 0

        admins_info = ActiveSupport::JSON.decode self.admins_info
        admins_info.delete_if{|rec| rec['admin_id'] == user.id}
        self.admins_info = ActiveSupport::JSON.encode admins_info
        self.save
      end

      def admin_level_of(admin)
        admin_positions = ActiveSupport::JSON.decode self.admins_info
        index = admin_positions.index{|item| item['admin_id'] == admin.id}
        raise "admin is not admin" unless index
        admin_positions[index]['admin_level']
      end

      def include_admin?(user)
        check_user user

        admin_positions = ActiveSupport::JSON.decode self.admins_info
        (admin_positions.index{|item| item['admin_id'] == user.id}) ? true : false
      end

      def add_post(options = {})
        options.symbolize_keys!
        user = options[:user]
        post = options[:post]
        raise "user should be passed in params" unless user
        raise "user should be a member of community" unless self.include_user?(user)
        raise "post should be passed in params" unless post
        check_post post
        user_id_attr = "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
        raise "user tried to add post of another user" unless post.send(user_id_attr) == user.id
        raise "post is already added to this community" if post.communities_row.include? self.id

        ::Inkwell::BlogItem.create :owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY, :item_id => post.id, :item_type => ItemTypes::POST
        communities_ids = ActiveSupport::JSON.decode post.communities_ids
        communities_ids << self.id
        post.communities_ids = ActiveSupport::JSON.encode communities_ids
        post.save

        users_with_existing_items = [user.id]
        ::Inkwell::TimelineItem.where(:item_id => post.id, :item_type => ItemTypes::POST).each do |item|
          users_with_existing_items << item.owner_id
          item.has_many_sources = true
          from_source = ActiveSupport::JSON.decode item.from_source
          from_source << Hash['community_id' => self.id]
          item.from_source = ActiveSupport::JSON.encode from_source
          item.save
        end

        self.users_row.each do |user_id|
          next if users_with_existing_items.include? user_id
          ::Inkwell::TimelineItem.create :item_id => post.id, :owner_id => user_id, :owner_type => OwnerTypes::USER, :item_type => ItemTypes::POST,
                                         :from_source => ActiveSupport::JSON.encode([Hash['community_id' => self.id]])
        end
      end

      def remove_post(options = {})
        options.symbolize_keys!
        user = options[:user]
        post = options[:post]
        raise "user should be passed in params" unless user
        raise "user should be a member of community" unless self.include_user?(user)
        raise "post should be passed in params" unless post
        check_post post
        user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
        user_id_attr = "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
        if self.include_admin?(user)
          post_owner = user_class.find post.send(user_id_attr)
          raise "admin tries to remove post of another admin. not enough permissions" if
              (self.include_admin? post_owner) && (self.admin_level_of(user) > self.admin_level_of(post_owner))
        else
          raise "user tried to remove post of another user" unless post.send(user_id_attr) == user.id
        end
        raise "post isn't in community" unless post.communities_row.include? self.id

        ::Inkwell::BlogItem.delete_all :owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY, :item_id => post.id, :item_type => ItemTypes::POST
        communities_ids = ActiveSupport::JSON.decode post.communities_ids
        communities_ids.delete self.id
        post.communities_ids = ActiveSupport::JSON.encode communities_ids
        post.save

        items = ::Inkwell::TimelineItem.where(:item_id => post.id, :item_type => ItemTypes::POST).where("from_source like '%{\"community_id\":#{self.id}%'")
        items.where(:has_many_sources => false).delete_all
        items.where(:has_many_sources => true).each do |item|
          from_source = ActiveSupport::JSON.decode item.from_source
          from_source.delete Hash['community_id' => self.id]
          item.from_source = ActiveSupport::JSON.encode from_source
          item.has_many_sources = false if from_source.size < 2
          item.save
        end
      end

      def blogline(options = {})
        options.symbolize_keys!
        last_shown_obj_id = options[:last_shown_obj_id]
        limit = options[:limit] || 10
        for_user = options[:for_user]

        if last_shown_obj_id
          blog_items = ::Inkwell::BlogItem.where(:owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY).where("created_at < ?", Inkwell::BlogItem.find(last_shown_obj_id).created_at).order("created_at DESC").limit(limit)
        else
          blog_items = ::Inkwell::BlogItem.where(:owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY).order("created_at DESC").limit(limit)
        end

        post_class = Object.const_get ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize
        result = []
        blog_items.each do |item|
          if item.is_comment
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

      def users_row
        ActiveSupport::JSON.decode self.users_ids
      end

      def create_invitation_request(user)
        raise "invitation request was already created" if self.include_invitation_request? user
        raise "it is impossible to create request. user is banned in this community" if self.include_banned_user? user
        raise "it is impossible to create request for public community" if self.public

        invitations_uids = ActiveSupport::JSON.decode self.invitations_uids
        invitations_uids << user.id
        self.invitations_uids = ActiveSupport::JSON.encode invitations_uids
        self.save
      end

      def accept_invitation_request(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        check_user user
        check_user admin
        raise "admin is not admin in this community" unless self.include_admin? admin
        raise "this user is already in this community" if self.include_user? user
        raise "there is no invitation request for this user" unless self.include_invitation_request? user

        self.add_user :user => user

        remove_invitation_request user
      end

      def reject_invitation_request(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        check_user user
        check_user admin
        raise "there is no invitation request for this user" unless self.include_invitation_request? user
        raise "admin is not admin in this community" unless self.include_admin? admin

        remove_invitation_request user
      end

      def include_invitation_request?(user)
        raise "invitations work only for private community. this community is public." if self.public
        invitations_uids = ActiveSupport::JSON.decode self.invitations_uids
        (invitations_uids.index{|uid| uid == user.id}) ? true : false
      end



      private

      def remove_invitation_request(user)
        invitations_uids = ActiveSupport::JSON.decode self.invitations_uids
        invitations_uids.delete user.id
        self.invitations_uids = ActiveSupport::JSON.encode invitations_uids
        self.save
      end

      def processing_a_community
        user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
        owner = user_class.find self.owner_id

        communities_info = ActiveSupport::JSON.decode owner.communities_info
        communities_info << Hash[HashParams::COMMUNITY_ID => self.id, HashParams::ACCESS_LEVEL => self.default_user_access]
        owner.communities_info = ActiveSupport::JSON.encode communities_info
        owner.save

        admins_info = [Hash['admin_id' => owner.id, 'admin_level' => 0]]
        self.admins_info = ActiveSupport::JSON.encode admins_info
        self.users_ids = ActiveSupport::JSON.encode [owner.id]
        self.writers_ids = ActiveSupport::JSON.encode [owner.id]
        self.save
      end

      def destroy_community_processing
        user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
        users_ids = ActiveSupport::JSON.decode self.users_ids
        users_ids.each do |user_id|
          user = user_class.find user_id
          communities_info = ActiveSupport::JSON.decode user.communities_info
          communities_info.delete_if {|item| item[HashParams::COMMUNITY_ID] == self.id}
          user.communities_info = ActiveSupport::JSON.encode communities_info
          user.save
        end

        timeline_items = ::Inkwell::TimelineItem.where "from_source like '%{\"community_id\":#{self.id}%'"
        timeline_items.delete_all :has_many_sources => false
        timeline_items.each do |item|
          from_source = ActiveSupport::JSON.decode item.from_source
          from_source.delete_if { |rec| rec['community_id'] == self.id }
          item.from_source = ActiveSupport::JSON.encode from_source
          item.has_many_sources = false if from_source.size < 2
          item.save
        end

        ::Inkwell::BlogItem.delete_all :owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY

      end
    end
  end
end

::ActiveRecord::Base.send :include, ::Inkwell::ActsAsInkwellCommunity::Base