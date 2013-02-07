# encoding: utf-8

module MongoMapper
  module Plugins
    module PublishingLogic
      extend ActiveSupport::Concern


      mattr_accessor :publishing_logic_active
      self.publishing_logic_active = true

      included do

        # published_state is a cached state to allow querying without duplicating any logic.
        key :published_state, Boolean, default: false, required: true

        key :published_flag, Boolean, default: false, required: true
        key :publishing_date, Date, default: PublishingLogic::today.to_date, required: true
        key :publishing_end_date, Date, default: nil # optional

        before_save :cache_published_state

        scope :published, lambda {
          PublishingLogic::publishing_logic_active ?  where(published_state: true) : where()
        }

        scope :unpublished, lambda {
          PublishingLogic::publishing_logic_active ?  where(:published_state.ne => true) : where(:$not => true)
        }

        # prepared: published, but publishing start date is not yet reached
        # TODO test, doc
        scope :prepared, lambda {
          unpublished.where(published_flag: true, :publishing_date.gt => PublishingLogic::today)
        }

        # expired: published, but publishing end date is reached
        # TODO test, doc
        scope :expired, lambda {
          unpublished.where(
            published_flag: true,
            :publishing_end_date.ne => nil, :publishing_end_date.lt => PublishingLogic::today
          )
        }

      end


      # ***************** INSTANCE METHODS ******************


      def published?
        PublishingLogic::publishing_logic_active ? determine_published_state : true
      end


      def determine_published_state
        start_date_ok = (publishing_date <= PublishingLogic::today.to_date)
        end_date_ok = publishing_end_date.nil? || (publishing_end_date >= PublishingLogic::today.to_date)
        return self.published_flag && start_date_ok && end_date_ok
      end


      def cache_published_state
        self.published_state = determine_published_state
        return true
      end


      module ModuleMethods

        # TODO test
        def activate
          PublishingLogic::publishing_logic_active = true
        end


        # TODO test
        def deactivate
          PublishingLogic::publishing_logic_active = false
        end


        # runs a block with activated or deactivated publishing logic,
        # depending on param active_flag
        def with_status(active_flag = true, &block)
          active_flag ? yield : self.deactivated { yield }
        end


        # runs a block with deactivated publishing logic
        def deactivated(&block)
          begin
            PublishingLogic::deactivate
            yield
          ensure
            PublishingLogic::activate
          end
        end


        def today
          return ActiveSupport::TimeZone["UTC"].now.beginning_of_day
        end

      end

      extend self::ModuleMethods

    end
  end
end
