    -- Modify the root span
    local root_span = kong.tracing.active_span()
    local apikey = kong.request.get_header("apikey")

    if apikey then
        root_span:set_attribute("apikey", apikey)
    else
        kong.log.warn("No 'apikey' found in request headers")
    end