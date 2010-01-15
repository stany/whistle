ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES << 'jquery-clear-on-click' unless ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES.blank?
ActionView::Helpers::AssetTagHelper::reset_javascript_include_default
