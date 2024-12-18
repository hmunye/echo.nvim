describe("echo", function()
    it("is requirable", function()
        require("echo")
    end)

    it("minimal setup functions correctly", function()
        require("echo").setup({
            model = "mistral:latest",
        })
    end)
end)
