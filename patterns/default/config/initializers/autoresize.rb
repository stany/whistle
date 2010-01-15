ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES << 'jquery-autoresize' unless ActionView::Helpers::AssetTagHelper::JAVASCRIPT_DEFAULT_SOURCES.blank?
ActionView::Helpers::AssetTagHelper::reset_javascript_include_default
