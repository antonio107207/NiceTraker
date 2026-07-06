module PortalHelper
  def portal_nav_link(label, path, icon:)
    active = current_page?(path) || request.path.start_with?(path.sub(/\/$/, ""))
    active_classes  = "bg-indigo-600/20 text-indigo-300"
    default_classes = "text-slate-400 hover:bg-slate-800 hover:text-white"

    link_to path, class: "flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors #{active ? active_classes : default_classes}" do
      concat content_tag(:svg, raw(icon), class: "w-4.5 h-4.5 w-[18px] h-[18px] shrink-0", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24")
      concat content_tag(:span, label)
    end
  end
end
