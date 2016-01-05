# Helpers
helpers do
  # nav_link_to("Home", "/home", :root => true, :class => "foo")
  def nav_link_to(link_text, url, options = {})
    root = options.delete(:root)
    is_active = (!root && current_page.url.start_with?(url)) ||
      current_page.url == url
    options[:class] ||= ''
    options[:class] << '--is-active' if is_active
    link_to(link_text, url, options)
  end

  def recent_release_post
    blog.articles.find { |a| a.tags.include?("release") }
  end
end

# Blog
activate :blog do |blog|
  blog.prefix = 'blog'
  blog.permalink = '{title}.html'
  blog.layout = 'article'
  blog.paginate = true
  blog.per_page = 2
end

# Syntax highlighting
activate :syntax

# Pretty URLs (Directory Indexes)
activate :directory_indexes

# Deployment
activate :deploy do |deploy|
  deploy.method = :git
end

# Assets configuration
set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'

# Markdown configration
set :markdown_engine, :kramdown

# Set layouts
page 'guides/*', :layout => :sidebar
page 'feed.xml', :layout => :feed

# Development-specific configuration
configure :development do
  activate :livereload
end

set :url_root, 'http://padrinorb.com'

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  activate :relative_assets
  activate :search_engine_sitemap,
    exclude_if: -> (resource) {
      # Exclude all paths from sitemap that are sub-date indexes
      resource.path.match(/[0-9]{4}(\/[0-9]{2})*.html/)
    }, default_change_frequency: 'weekly'
  activate :robots, :rules => [
    {:user_agent => '*', :allow => %w(/), :disallow => %w(CNAME /*.js /*.css)}
  ], :sitemap => 'http://padrinorb.com/sitemap.xml'
end
