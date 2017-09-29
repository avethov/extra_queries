module ExtraQueries
  module SortHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :sort_update, :eq
      end
    end

    module InstanceMethods
      def sort_update_with_eq(criteria, sort_name=nil)
        res = sort_update_without_eq(criteria, sort_name)
        if Setting.plugin_extra_queries['custom_query_timelog_page_enabled'] && controller_name == "timelog"
          @query.sort_criteria = @sort_criteria.to_a
        end
        res
      end
    end
  end
end