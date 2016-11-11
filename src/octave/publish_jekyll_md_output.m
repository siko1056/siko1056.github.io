function outstr = publish_jekyll_md_output (varargin)
  ##
  ## Types to handle are:
  ##
  ## * "header" (title_str, intro_str, toc_cstr)
  ## * "footer" ()
  ## * "code" (str)
  ## * "code_output" (str)
  ## * "section" (str)
  ## * "preformatted_code" (str)
  ## * "preformatted_text" (str)
  ## * "bulleted_list" (cstr)
  ## * "numbered_list" (cstr)
  ## * "graphic" (str)
  ## * "html" (str)
  ## * "latex" (str)
  ## * "text" (str)
  ## * "bold" (str)
  ## * "italic" (str)
  ## * "monospaced" (str)
  ## * "link" (url_str, str)
  ## * "TM" ()
  ## * "R" ()
  ##
  eval (["outstr = handle_", varargin{1}, " (varargin{2:end});"]);
endfunction

function outstr = handle_header (title_str, intro_str, toc_cstr)
  outstr = ["---\n", ...
    "layout: post\n", ...
    "title: ", title_str, "\n", ...
    "date: ", datestr(now (), "yyyy-mm-dd"), "\n", ...
    "---\n\n", intro_str, ...
    "\n* TOC\n{:toc}\n\n"];
endfunction

function outstr = handle_footer (m_source_str)
  outstr = ["\n\nPublished with GNU Octave ", version()];
endfunction

function outstr = handle_code (str)
  outstr = ["\n{% highlight octave %}\n", str, "\n{% endhighlight %}\n"];
endfunction

function outstr = handle_code_output (str)
  outstr = ["\n{% highlight text %}\n", str, "\n{% endhighlight %}\n"];
endfunction

function outstr = handle_section (varargin)
  outstr = ["\n# ", varargin{1}, "\n"];
endfunction

function outstr = handle_preformatted_code (str)
  outstr = handle_code (str);
endfunction

function outstr = handle_preformatted_text (str)
  outstr = handle_code_output (str);
endfunction

function outstr = handle_bulleted_list (cstr)
  outstr = "\n";
  for i = 1:length(cstr)
    outstr = [outstr, "* ", cstr{i}, "\n"];
  endfor
  outstr = [outstr, "\n"];
endfunction

function outstr = handle_numbered_list (cstr)
  outstr = "\n";
  for i = 1:length(cstr)
    outstr = [outstr, num2str(i),". ", cstr{i}, "\n"];
  endfor
  outstr = [outstr, "\n"];
endfunction

function outstr = handle_graphic (str)
  str = ["/src/octave/html/", str];
  outstr = ["!", handle_link(str, str)];
endfunction

function outstr = handle_html (str)
  outstr = str;
endfunction

function outstr = handle_latex (str)
  outstr = "";
endfunction

function outstr = handle_link (url_str, str)
  outstr = ["[", str,"](", url_str, ")"];
endfunction

function outstr = handle_text (str)
  outstr = ["\n", str, "\n"];
endfunction

function outstr = handle_bold (str)
  outstr = ["**", str, "**"];
endfunction

function outstr = handle_italic (str)
  outstr = ["*", str, "*"];
endfunction

function outstr = handle_monospaced (str)
  outstr = ["`", str, "`"];
endfunction

function outstr = handle_TM ()
  outstr = "&trade;";
endfunction

function outstr = handle_R ()
  outstr = "&reg;";
endfunction
