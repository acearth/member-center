module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = 'Member Center'
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end


  def url_with(locale)
    uri = URI.parse(request.original_url)
    return request.original_url + '?locale=' + locale unless uri.query
    params = CGI.parse(uri.query)
    params['locale'] = locale
    "http://#{uri.host}:#{uri.port}/#{uri.path}?#{ params.to_query}"
  end
end
