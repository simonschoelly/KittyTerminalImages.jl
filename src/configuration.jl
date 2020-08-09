
# TODO there might be Julia library for handling such configurations
# TODO maybe add possibility to add config values from Environment
# TODO add way to validate value and type of configs


config_values = Dict{Symbol, Any}()


supported_config_keys = [:scale]


function set_kitty_config!(key, value)

    if key ∉ supported_config_keys
        throw(DomainError(key, "$key is not a valid config key. Valid keys are $supported_config_keys"))
    end

    config_values[key] = value
    return nothing
end

get_kitty_config(key::Symbol) = config_values[key]
get_kitty_config(key::Symbol, default) = get(config_values, key, default)
