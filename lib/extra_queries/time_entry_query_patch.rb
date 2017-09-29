module ExtraQueries
  module TimeEntryQueryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        self.available_columns << QueryAssociationColumn.new(:category, :issue, :sortable => "#{IssueCategory.table_name}.name", :groupable => true)
        self.available_columns << QueryAssociationColumn.new(:tracker, :issue, :sortable => "#{Tracker.table_name}.name", :groupable => true)
        tweek_index = self.available_columns.find_index {|x| x.name == :tweek}
        if tweek_index
          self.available_columns[tweek_index] = QueryColumn.new(:tweek, :sortable => ["#{TimeEntry.table_name}.spent_on", "#{TimeEntry.table_name}.created_on"], :caption => :label_week)
        end
        alias_method_chain :initialize_available_filters, :eq
        alias_method_chain :build_from_params, :eq
      end
    end

    module InstanceMethods
      def initialize_available_filters_with_eq
        initialize_available_filters_without_eq
        add_available_filter 'tracker', type: :list, values: trackers.map { |s| [s.name, s.id.to_s] }, label: :field_tracker
        add_available_filter 'category', type: :list, values: (project.nil? ? IssueCategory.joins(:project) : project.issue_categories).map { |s| [s.name, s.id.to_s] }, label: :field_category
      end

      def sql_for_tracker_field(field, operator, value, options={})
        sql = case operator
                when '=', '!'
                 "#{Issue.table_name}.tracker_id " + (operator == '=' ? '' : 'NOT') + " IN (#{value.join(', ')})"
                else
                 '1=0'
              end
        "(#{sql})"
      end

      def sql_for_category_field(field, operator, value, options={})
        sql = case operator
                when '=', '!'
                  "#{Issue.table_name}.category_id " + (operator == '=' ? '' : 'NOT') + " IN (#{value.join(', ')})"
                else
                  '1=0'
              end
        "(#{sql})"
      end

      def build_from_params_with_eq(params)
        res = build_from_params_without_eq(params)
        unless Setting.plugin_extra_queries['custom_query_timelog_page_enabled']
          return res
        end
        if params[:sort_criteria] && params[:sort].blank?
          params[:sort] = (params[:sort_criteria].map { |k,v| (v || []).join(':') } || []).join(',')
          res.sort_criteria = params.delete(:sort_criteria) || []
        end
        res
      end
    end
  end
end