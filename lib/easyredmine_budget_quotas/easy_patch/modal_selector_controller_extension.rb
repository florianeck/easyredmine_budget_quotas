module EasyPatch
  module ModelSelectorControllerExtension
    def time_entry_activity
      retrieve_query(EasyActivityQuery)
      @query.name = l("label_activity")

      set_query(@query)

      prepare_easy_query_render

      if request.xhr? && !@entities
        render_404
        return false
      end

      if loading_group?
        render_easy_query_html(@query, nil, {:selected_values => prepare_selected_values})
      else
        render_modal_selector_entities_list(@query, @entities, @entity_pages, @entity_count)
      end
    end
  end
end