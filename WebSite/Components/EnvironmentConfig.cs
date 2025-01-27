namespace cdnapp.Components;
public class EnvironmentConfig
{
    public required string BlobBaseImageUrl { get; set; }
    public required string CdnBaseImageUrl { get; set; }

    //IsConfigured
    public bool IsConfigured => !string.IsNullOrEmpty(BlobBaseImageUrl) && 
                                !string.IsNullOrEmpty(CdnBaseImageUrl) &&
                                BlobBaseImageUrl != "https://example.com/images" &&
                                CdnBaseImageUrl != "https://example.com/images";

}