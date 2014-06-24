sampler2D inputTexture : register(s0);

float4 main(float2 uv : TEXCOORD) : COLOR 
{ 	
	float4 color; 
	float4 contrastColor;
	float4 tonedColor;
	color = tex2D(inputTexture , uv.xy);
	contrastColor = ContrastAdjustments(color);
	tonedColor = ColorTone(contrastColor);

	return tonedColor; 
}

float4 ContrastAdjustments(float4 inputColor)
{
		
		float Brightness = 0.0;
		float Contrast = 2.18;
		

    float4 pixelColor = inputColor;
    pixelColor.rgb /= pixelColor.a;
    
    
    pixelColor.rgb = ((pixelColor.rgb - 0.5f) * max(Contrast, 0)) + 0.5f;
    
    
    pixelColor.rgb += Brightness;
    
    
    pixelColor.rgb *= pixelColor.a;
    return pixelColor;
}

float4 ColorTone(float4 inputColor)
{
		
		float Desaturation  = 0.25;
		float Toned = 0.44;
		float4 LightColor = float4(1.0,0.75,0.79,1.0);
		float4 DarkColor = float4(0.93,0.5,0.93,1.0);
		

		float4 color = inputColor;
    float3 scnColor = LightColor * (color.rgb / color.a);
    float gray = dot(float3(0.3, 0.59, 0.11), scnColor);
    
    float3 muted = lerp(scnColor, gray.xxx, Desaturation);
    float3 middle = lerp(DarkColor, LightColor, gray);
    
    scnColor = lerp(muted, middle, Toned);
    return float4(scnColor * color.a, color.a);
}