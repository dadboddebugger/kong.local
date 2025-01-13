    -- Modify the root span
    local root_span = kong.tracing.active_span()
    local body, err = kong.request.get_body()

    if err then
        kong.log.err("Failed to read request body: ", err)
    else
    -- Set the body as an attribute in the root span
        root_span:set_attribute("prompt", body)
    end