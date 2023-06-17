using Microsoft.AspNetCore.Mvc;
using RGB.NET.Core;
using SteelSeriesApi.Managers;
using SteelSeriesApi.Models;

namespace SteelSeriesApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SteelSeriesController : ControllerBase
    {
        private readonly SteelSeriesManager _steelSeriesManager;
        private readonly ILogger<SteelSeriesController> _logger;

        public SteelSeriesController(
            SteelSeriesManager steelSeriesManager,            
            ILogger<SteelSeriesController> logger)
        {
            _steelSeriesManager = steelSeriesManager;
            _logger = logger;
        }

        [HttpPost("key_color")]
        public async Task<IActionResult> KeyColor(
            [FromBody] KeyColor keyColor,
            CancellationToken cancellationToken)
        {
            _steelSeriesManager.SetLedColor((LedId)keyColor.Key, new Color(keyColor.Red, keyColor.Green, keyColor.Blue));            

            return Ok("Key color set successfully");
        }
    }
}