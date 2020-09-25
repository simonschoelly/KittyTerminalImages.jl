
# TODO there might be Julia library for handling such configurations
# TODO maybe add possibility to add config values from Environment
# TODO add way to validate value and type of configs


config_values = Dict{Symbol, Any}()


supported_config_keys = [:scale, :transfer_mode]


function set_kitty_config!(key, value)

    if key ∉ supported_config_keys
        throw(DomainError(key, "$key is not a valid config key. Valid keys are $supported_config_keys"))
    end

    # TODO this could be handled more general
    if key == :transfer_mode
        if value ∉ (:direct, :temp_file)
            throw(DomainError(value, "value for key :transfer_mode must be either :direct or temp_file"))
        end
    end

    config_values[key] = value
    return nothing
end

get_kitty_config(key::Symbol) = config_values[key]
get_kitty_config(key::Symbol, default) = get(config_values, key, default)

# insert some default
set_kitty_config!(:transfer_mode, :direct)
