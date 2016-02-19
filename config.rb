###
# Settings
###

set :url_root, 'http://padrinorb.com'
set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'
set :markdown_engine, :redcarpet
set :markdown, :tables => true, :autolink => true, :gh_blockcode => true,
    :fenced_code_blocks => true

###
# Helpers
###

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
    blog.articles.find { |a| a.tags.include?('release') }
  end

  def guides
    resources = sitemap.resources.select do |r|
      r.path.start_with?('guides/') && !r.path.match(/^guides\/\d{2}_/) && r.path != 'guides/README.html'
    end
  end

  def guides_by_chapter
    guides.group_by { |c| c.data.chapter }
  end
end

###
# Extensions
###

activate :blog do |blog|
  blog.prefix = 'blog'
  blog.permalink = '{title}.html'
  blog.layout = 'article'
  blog.paginate = true
  blog.per_page = 2
end
activate :syntax
activate :directory_indexes
activate :deploy do |deploy|
  deploy.method = :git
end

###
# Pages
###

page 'feed.xml', :layout => :feed
page 'guides/*', :layout => :guide

ready do
  sitemap.resources.select { |r| r.path.start_with?('guides/') }.each do |resource|
    path = resource.path.split('/')

    if path.size >= 3
      chapter = path[1][3..-1]
      title = path[2][3..-1]
      locals = { sidebar: 'layouts/guides_sidebar' }
      proxy "guides/#{chapter}/#{title}", path.join('/'), locals: locals
    end
  end
end

###
# Environment Configuration
###

configure :development do
  activate :livereload
end

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
