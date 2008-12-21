module ContextsHelper
  def link_to_context(ctx)
    link_to h(ctx ? ctx.name : :etc), url_for_context(perma)
  end

  def url_for_context(ctx)
    context_path(ctx ? ctx.permalink : :etc)
  end
end
