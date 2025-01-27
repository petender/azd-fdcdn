using cdnapp.Components;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

// Read environment variables
var environmentConfig = new EnvironmentConfig
{
    BlobBaseImageUrl = builder.Configuration["BLOB_BASE_IMAGE_URL"] ?? "https://example.com/images",
    CdnBaseImageUrl = builder.Configuration["CDN_BASE_IMAGE_URL"] ?? "https://example.com/images",
};

// Register EnvironmentConfig as a singleton service
builder.Services.AddSingleton(environmentConfig);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
  
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.MapStaticAssets();
app.MapRazorPages()
   .WithStaticAssets();

app.Run();


