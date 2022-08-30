import HTTP, EzXML

function main()
    response = HTTP.get("https://www.bemadiscipleship.com/rss")
    parsed = parsexml(String(response.body))
    elements = root(parsed)
    items = findall("rss/channel/item", elements)
    for item in items
        downloader(item)
    end
end

function pad_title(title::AbstractString)
    parts = split(title, ':')
    number = parse(UInt16, shift!(parts))
    string(lpad(number, 3, '0'), ':', join(parts, ""))
end

function weirdo_title(title::AbstractString)
    if title == "“Jesus Shema”"
        return string("021b: " title)
    elseif title == "Verastikh (Hosea)"
        return string("049b: " title)
    end
end

function handle_title(title::AbstractString)
    deslashed = replace(title, "/" => "_")
    if ':' in title
        pad_title(title)
    else
        weirdo_title(title)
    end
end

function downloader(item::EzXML.Node)
    title = nodecontent(findfirst("title"))
    filename = handle_title(title)
    enclosure_attrs = attributes(findfirst("enclosure", item))
    url = nodecontent(enclosure_attrs[1])
    if !file_exists(filename)
        fetch(filename)
    end
end

main()
