using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using cdnapp.Components;

namespace cdnapp.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;
    public required EnvironmentConfig Config;

    public IndexModel(ILogger<IndexModel> logger, EnvironmentConfig config)
    {
        _logger = logger;
        Config = config;
    }

    public void OnGet()
    {

    }
}
