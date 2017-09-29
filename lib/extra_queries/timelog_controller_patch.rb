module ExtraQueries
  module TimelogControllerPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        helper :issues_extend

        alias_method_chain :index, :eq
        alias_method_chain :report, :eq
        alias_method_chain :time_entry_scope, :eq
      end
    end

    module InstanceMethods
      def index_with_eq
        if Setting.plugin_extra_queries['custom_query_timelog_page_enabled']
          prepend_view_path File.join(Redmine::Plugin.find(:extra_queries).directory, 'app', 'views', 'extra_queries')
        end

        index_without_eq
      end

      def report_with_eq
        if Setting.plugin_extra_queries['custom_query_timelog_page_enabled']
          prepend_view_path File.join(Redmine::Plugin.find(:extra_queries).directory, 'app', 'views', 'extra_queries')
        end

        report_without_eq
      end

      def time_entry_scope_with_eq(options={})
        scope = time_entry_scope_without_eq(options)
        scope.includes({issue: [:category, :tracker]})
      end
    end
  end
end