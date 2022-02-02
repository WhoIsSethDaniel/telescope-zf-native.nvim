local zf = require("zf")
local sorters = require("telescope.sorters")

local make_sorter = function(opts)
    opts = vim.tbl_deep_extend("force", {
        highlight_results = true,
        match_filename = true,
    }, opts or {})

    return sorters.new({
        start = function(self, prompt)
            self.tokens = zf.tokenize(prompt)
        end,
        scoring_function = function(self, _, line)
            if self.tokens == nil then return 1 end

            local rank = zf.rank(line, self.tokens.tokens, self.tokens.len, opts.match_filename)
            if rank == -1 then return rank end

            return 1.0 - (1.0 / rank)
        end,
        -- TODO: add highlighter (depends on zf returning range info)
        -- highlighter = function(self, prompt, display)
        -- end
    })
end

local default_config = {
    file = {
        -- override default telescope file sorter
        enable = true,

        -- highlight matching text in results
        highlight_results = true,

        -- enable zf filename match priority
        match_filename = true,
    },
    generic = {
        -- override default telescope generic item sorter
        enable = true,

        -- highlight matching text in results
        highlight_results = true,

        -- disable zf filename match priority
        match_filename = false,
    },
}

return require("telescope").register_extension({
    setup = function(ext_config, config)
        local opts = vim.tbl_deep_extend("force", default_config, ext_config or {})

        if opts.file.enable then
            config.file_sorter = function()
                return make_sorter(opts.file)
            end
        end

        if opts.generic.enable then
            config.generic_sorter = function()
                return make_sorter(opts.generic)
            end
        end
    end,

    exports = {
        native_zf_scorer = function(opts)
            return make_sorter(opts)
        end,
    },
})
