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

        if ::Inkwell::Engine::config.respond_to?('community_table')
          has_many :communities_users, :class_name => 'Inkwell::CommunityUser'
          has_many :users, -> { where "inkwell_community_users.active" => true}, :through => :communities_users, :class_name => ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
          has_many :admins, -> { where "inkwell_community_users.is_admin" => true, "inkwell_community_users.active" => true}, :through => :communities_users, :class_name => ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
          has_many :writers, -> { where "inkwell_community_users.user_access" => ::Inkwell::Constants::CommunityAccessLevels::WRITE, "inkwell_community_users.active" => true}, :through => :communities_users, :class_name => ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
          has_many :muted_users, -> { where "inkwell_community_users.muted" => true, "inkwell_community_users.active" => true}, :through => :communities_users, :class_name => ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
          has_many :banned_users, -> { where "inkwell_community_users.banned" => true}, :through => :communities_users, :class_name => ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
          has_many :asked_invitation_users, -> { where "inkwell_community_users.asked_invitation" => true}, :through => :communities_users, :class_name => ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
          has_many :blog_items, -> { where :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY}, :class_name => 'Inkwell::BlogItem', :foreign_key => :owner_id
          has_many ::Inkwell::Engine::config.post_table, -> { where "inkwell_blog_items.item_type" => ::Inkwell::Constants::ItemTypes::POST}, :class_name => ::Inkwell::Engine::config.post_table.to_s.singularize.capitalize, :through => :blog_items
        end

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
        check_user user

        relation = ::Inkwell::CommunityUser.where(user_id_attr => user.id, community_id_attr => self.id).first

        if relation
          raise "this user is already in this community" if relation.active
          raise "this user is banned" if relation.banned

          relation.asked_invitation = false if relation.asked_invitation
          relation.user_access = self.default_user_access
          relation.active = true
          relation.save
        else
          relation = ::Inkwell::CommunityUser.create user_id_attr => user.id, community_id_attr => self.id, :user_access => self.default_user_access, :active => true
        end


        self.user_count += 1
        self.writer_count += 1 if relation.user_access == CommunityAccessLevels::WRITE
        self.save
        user.community_count += 1
        user.save

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

        relation = ::Inkwell::CommunityUser.where(user_id_attr => user.id, community_id_attr => self.id).first

        self.user_count -= 1
        self.writer_count -= 1 if relation.user_access == CommunityAccessLevels::WRITE
        self.admin_count -= 1 if relation.is_admin
        self.muted_count -= 1 if relation.muted
        self.save
        user.community_count -= 1
        user.save

        if relation.muted
          relation.active = false
          relation.save
        else
          relation.destroy
        end

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

      def include_writer?(user)
        check_user user
        ::Inkwell::CommunityUser.exists? user_id_attr => user.id, community_id_attr => self.id, :user_access => CommunityAccessLevels::WRITE, :active => true
      end

      def include_user?(user)
        check_user user
        ::Inkwell::CommunityUser.exists? user_id_attr => user.id, community_id_attr => self.id, :active => true
      end

      def mute_user(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        raise "user should be passed in params" unless user
        raise "admin should be passed in params" unless admin
        check_user user
        check_user admin

        relation = ::Inkwell::CommunityUser.where(user_id_attr => user.id, community_id_attr => self.id).first

        raise "admin is not admin" unless self.include_admin? admin
        raise "user should be a member of this community" unless relation
        raise "this user is already muted" if relation.muted
        raise "it is impossible to mute yourself" if user == admin
        raise "admin has no permissions to mute this user" if (relation.is_admin) && (admin_level_of(admin) >= relation.admin_level)

        relation.muted = true
        relation.save

        self.muted_count += 1
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

        relation = ::Inkwell::CommunityUser.where(user_id_attr => user.id, community_id_attr => self.id).first

        raise "admin is not admin" unless self.include_admin? admin
        raise "user should be a member of this community" unless relation
        raise "this user is not muted" unless relation.muted
        raise "admin has no permissions to unmute this user" if (relation.is_admin) && (admin_level_of(admin) >= relation.admin_level)

        relation.muted = false
        relation.save

        self.muted_count -= 1
        self.save
      end

      def include_muted_user?(user)
        check_user user
        ::Inkwell::CommunityUser.exists? user_id_attr => user.id, community_id_attr => self.id, :muted => true, :active => true
      end

      def muted_row
        relations = ::Inkwell::CommunityUser.where community_id_attr => self.id, :muted => true
        result = []
        relations.each do |relation|
          result << relation.send(user_id_attr)
        end
        result
      end

      def ban_user(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        raise "user should be passed in params" unless user
        raise "admin should be passed in params" unless admin
        check_user user
        check_user admin
        raise "admin is not admin" unless self.include_admin? admin
        raise "admin has no permissions to ban this user" if (self.include_admin? user) && (admin_level_of(admin) >= admin_level_of(user))

        relation = ::Inkwell::CommunityUser.where(user_id_attr => user.id, community_id_attr => self.id).first
        raise "user should be a member of community or send invitation request to it" unless relation
        raise "this user is already banned" if relation.banned
        relation.banned = true
        relation.active = false
        if relation.asked_invitation
          relation.asked_invitation = false
          self.invitation_count -= 1
        else
          self.user_count -= 1
        end
        relation.save

        self.banned_count += 1
        self.save
      end

      def unban_user(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        raise "user should be passed in params" unless user
        raise "admin should be passed in params" unless admin
        check_user user
        check_user admin
        raise "admin is not admin" unless self.include_admin? admin

        relation = ::Inkwell::CommunityUser.where(user_id_attr => user.id, community_id_attr => self.id).first
        raise "this user is not banned" unless relation || relation.banned

        relation.banned = false
        relation.active = true unless relation.asked_invitation
        relation.save

        self.banned_count -= 1
        self.save
      end

      def include_banned_user?(user)
        ::Inkwell::CommunityUser.exists? :community_id => self.id, :user_id => user.id, :banned => true
      end

      def banned_row
        relations = ::Inkwell::CommunityUser.where community_id_attr => self.id, :banned => true
        result = []
        relations.each do |relation|
          result << relation.send(user_id_attr)
        end
        result
      end

      def add_admin(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        raise "user should be passed in params" unless user
        raise "admin should be passed in params" unless admin
        check_user user
        check_user admin

        relation = ::Inkwell::CommunityUser.where(user_id_attr => user.id, community_id_attr => self.id).first

        raise "user should be in the community" unless relation
        raise "user is already admin" if relation.is_admin
        raise "admin is not admin" unless self.include_admin? admin
        raise "user should be a member of this community" unless relation

        if relation.muted
          relation.muted = false
          self.muted_count -= 1
        end
        unless relation.user_access == CommunityAccessLevels::WRITE
          relation.user_access = CommunityAccessLevels::WRITE
          self.writer_count += 1
        end
        relation.admin_level = admin_level_of(admin) + 1
        relation.is_admin = true
        relation.save

        self.admin_count += 1
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

        ::Inkwell::CommunityUser.where(user_id_attr => user.id, community_id_attr => self.id).update_all :is_admin => false, :admin_level => nil

        self.admin_count -= 1
        self.save
      end

      def admin_level_of(admin)
        relation = ::Inkwell::CommunityUser.where(user_id_attr => admin.id, community_id_attr => self.id).first
        raise "this user is not community member" unless relation
        raise "admin is not admin" unless relation.is_admin
        relation.admin_level
      end

      def include_admin?(user)
        check_user user
        ::Inkwell::CommunityUser.exists? user_id_attr => user.id, community_id_attr => self.id, :is_admin => true, :active => true
      end

      def add_post(options = {})
        options.symbolize_keys!
        user = options[:user]
        post = options[:post]
        raise "user should be passed in params" unless user
        raise "user should be a member of community" unless self.include_user? user
        raise "user is muted" if self.include_muted_user? user
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

        self.users_row.each do |uid|
          next if users_with_existing_items.include? uid
          ::Inkwell::TimelineItem.create :item_id => post.id, :owner_id => uid, :owner_type => OwnerTypes::USER, :item_type => ItemTypes::POST,
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
          blog_items = ::Inkwell::BlogItem.where(:id => blog_items_ids, :owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY).order("created_at DESC")
        else
          if last_shown_obj_id
            blog_items = ::Inkwell::BlogItem.where(:owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY).where("created_at < ?", Inkwell::BlogItem.find(last_shown_obj_id).created_at).order("created_at DESC").limit(limit)
          else
            blog_items = ::Inkwell::BlogItem.where(:owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY).order("created_at DESC").limit(limit)
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

      def users_row
        relations = ::Inkwell::CommunityUser.where community_id_attr => self.id
        result = []
        relations.each do |rel|
          result << rel.send(user_id_attr)
        end
        result
      end

      def writers_row
        relations = ::Inkwell::CommunityUser.where community_id_attr => self.id, :user_access => CommunityAccessLevels::WRITE
        result = []
        relations.each do |rel|
          result << rel.send(user_id_attr)
        end
        result
      end

      def readers_row
        users_row = self.users_row
        writers_row = self.writers_row
        users_row - writers_row
      end

      def admins_row
        relations = ::Inkwell::CommunityUser.where community_id_attr => self.id, :is_admin => true
        result = []
        relations.each do |rel|
          result << rel.send(user_id_attr)
        end
        result
      end

      def create_invitation_request(user)
        check_user user

        relation = ::Inkwell::CommunityUser.where(community_id_attr => self.id, user_id_attr => user.id).first
        if relation
          raise "invitation request was already created" if relation.asked_invitation
          raise "it is impossible to create request. user is banned in this community" if relation.banned
          raise "user is already community member" if relation.active
          raise "there is relation for user who is not member of community and he is not banned and not asked invitation to it"
        end
        raise "it is impossible to create request for public community" if self.public

        ::Inkwell::CommunityUser.create community_id_attr => self.id, user_id_attr => user.id, :asked_invitation => true, :active => false

        self.invitation_count += 1
        self.save
      end

      def accept_invitation_request(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        check_user user
        check_user admin
        raise "admin is not admin in this community" unless self.include_admin? admin

        relation = ::Inkwell::CommunityUser.where(community_id_attr => self.id, user_id_attr => user.id).first
        raise "this user is already in this community" if relation.active
        raise "there is no invitation request for this user" unless relation.asked_invitation

        self.add_user :user => user

        self.invitation_count -= 1
        self.save
      end

      def reject_invitation_request(options = {})
        options.symbolize_keys!
        user = options[:user]
        admin = options[:admin]
        check_user user
        check_user admin

        relation = ::Inkwell::CommunityUser.where(community_id_attr => self.id, user_id_attr => user.id).first
        raise "there is no invitation request for this user" unless relation || relation.asked_invitation
        raise "admin is not admin in this community" unless self.include_admin? admin

        relation.destroy

        self.invitation_count -= 1
        self.save
      end

      def include_invitation_request?(user)
        raise "invitations work only for private community. this community is public." if self.public
        ::Inkwell::CommunityUser.exists? community_id_attr => self.id, user_id_attr => user.id, :asked_invitation => true
      end

      def invitations_row
        relations = ::Inkwell::CommunityUser.where community_id_attr => self.id, :asked_invitation => true
        result = []
        relations.each do |relation|
          result << relation.send(user_id_attr)
        end
        result
      end

      def change_default_access_to_write
        unless self.default_user_access == CommunityAccessLevels::WRITE
          self.default_user_access = CommunityAccessLevels::WRITE
          self.save
        end
      end

      def change_default_access_to_read
        unless self.default_user_access == CommunityAccessLevels::READ
          self.default_user_access = CommunityAccessLevels::READ
          self.save
        end
      end

      def set_write_access(arr)
        raise "array with users objects or ids should be passed" unless arr.class == Array
        raise "empty array passed in params" if arr.empty?
        uids = []
        if arr[0].is_a? user_class
          arr.each do |user|
            uids << user.id
          end
        else
          uids = arr
        end
        relations = ::Inkwell::CommunityUser.where user_id_attr => uids, community_id_attr => self.id, :user_access => CommunityAccessLevels::READ, :is_admin => false
        raise "there is different count of passed users (#{uids.size}) and found users (#{relations.size}) in this community" unless relations.size == uids.size

        self.writer_count += relations.size
        self.save

        relations.update_all :user_access => CommunityAccessLevels::WRITE
      end

      def set_read_access(arr)
        raise "array with users ids should be passed" unless arr.class == Array
        raise "empty array passed in params" if arr.empty?
        uids = []
        if arr[0].is_a? user_class
          arr.each do |user|
            uids << user.id
          end
        else
          uids = arr
        end
        relations = ::Inkwell::CommunityUser.where user_id_attr => uids, community_id_attr => self.id, :user_access => CommunityAccessLevels::WRITE, :is_admin => false
        raise "there is different count of passed users (#{uids.size}) and found users (#{relations.size}) in this community" unless relations.size == uids.size

        self.writer_count -= relations.size
        self.save

        relations.update_all :user_access => CommunityAccessLevels::READ
      end

      def reader_count
        self.user_count - self.writer_count
      end

      #wrappers for category methods

      def create_category(options = {})
        options.symbolize_keys!
        options[:owner_id] = self.id
        options[:owner_type] = OwnerTypes::COMMUNITY
        category_class.create options
      end

      def get_categories
        category_class.get_categories_for :object => self, :type => OwnerTypes::COMMUNITY
      end

      private

      def processing_a_community
        owner = user_class.find self.owner_id
        owner.community_count += 1
        owner.save

        ::Inkwell::CommunityUser.create user_id_attr => self.owner_id, community_id_attr => self.id, :is_admin => true, :admin_level => 0,
                                        :user_access => CommunityAccessLevels::WRITE, :active => true
      end

      def destroy_community_processing
        users_ids = self.users_row
        users_ids.each do |uid|
          user = user_class.find uid
          user.community_count -= 1
          user.save
        end

        ::Inkwell::CommunityUser.delete_all community_id_attr => self.id

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

        if ::Inkwell::Engine::config.respond_to?('category_table')
          categories = category_class.where :owner_id => self.id, :owner_type => OwnerTypes::COMMUNITY
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

::ActiveRecord::Base.send :include, ::Inkwell::ActsAsInkwellCommunity::Base