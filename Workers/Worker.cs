using System.Diagnostics;
using Microsoft.AspNetCore;

namespace SteelSeriesApi.Workers
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;

        public Worker(ILogger<Worker> logger)
        {
            _logger = logger;
        }

        public ILogger Logger { get; }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Worker is starting.");

            stoppingToken.Register(() => _logger.LogInformation("Worker is stopping."));

            _logger.LogInformation("Worker has stopped.");
        }
    }
}