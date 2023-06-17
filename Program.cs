using Microsoft.Extensions.Hosting.WindowsServices;
using SteelSeriesApi.Managers;
using SteelSeriesApi.Workers;


// New-Service -Name "SteelSeriesApi" -BinaryPathName c:\Source\SteelSeriesApi\bin\Release\net7.0\publish\SteelSeriesApi.exe
// Start-Service -Name "SteelSeriesApi"
// Stop-Service -Name "SteelSeriesApi"
// Remove-Service -Name "SteelSeriesApi"
// sc.exe delete "SteelSeriesApi"

var webApplicationOptions = new WebApplicationOptions
{
    Args = args,
    ContentRootPath = WindowsServiceHelpers.IsWindowsService() ? AppContext.BaseDirectory : default
};
var builder = WebApplication.CreateBuilder(webApplicationOptions);

builder.Services
    .AddWindowsService()
    .AddSingleton<SteelSeriesManager>()
    .AddHostedService<Worker>()
    .AddControllers();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle  
builder.Services
    .AddEndpointsApiExplorer()
    .AddSwaggerGen();

builder.Host.UseWindowsService();

var app = builder.Build();

// Configure the HTTP request pipeline.  
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

await app.RunAsync();

