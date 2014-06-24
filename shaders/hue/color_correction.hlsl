
sampler2D inputTexture : register(s0);

float RGBCVtoHUE(in float3 RGB, in float C, in float V)
{
    float3 Delta = (V - RGB) / C;
    Delta.rgb -= Delta.brg;
    Delta.rgb += float3(2,4,6);
    
    Delta.brg = step(V, RGB) * Delta.brg;
    float H;
    H = max(Delta.r, max(Delta.g, Delta.b));
    return frac(H / 6);
}
 
float3 RGBtoHSV(in float3 RGB)
{
    float3 HSV = 0;
    HSV.z = max(RGB.r, max(RGB.g, RGB.b));
    float M = min(RGB.r, min(RGB.g, RGB.b));
    float C = HSV.z - M;
    if (C != 0)
    {
        HSV.x = RGBCVtoHUE(RGB, C, HSV.z);
        HSV.y = C / HSV.z;
    }
    return HSV;
}
 
float3 HUEtoRGB(in float H)
{
    float R = abs(H * 6 - 3) - 1;
    float G = 2 - abs(H * 6 - 2);
    float B = 2 - abs(H * 6 - 4);
    return saturate(float3(R,G,B));
}
 
float3 HSVtoRGB(float3 HSV)
{
    float3 RGB = HUEtoRGB(HSV.x);
    return ((RGB - 1) * HSV.y + 1) * HSV.z;
}
 
float3 HSVComplement(float3 HSV)
{
    
    float3 complement = HSV;
    complement.x -= 0.5;
    if (complement.x < 0.0) { complement.x += 1.0; }
    return(complement);
}
 
float HueLerp(float h1, float h2, float v)
{
    float d = abs(h1 - h2);
    if(d <= 0.5)
    {
        return lerp(h1, h2, v);
    }
    else if(h1 < h2)
    {
        return frac(lerp((h1 + 1.0), h2, v));
    }
    else
    {
        return frac(lerp(h1, (h2 + 1.0), v));
    }
}

float4 main(float2 uv : TEXCOORD, uniform float3 guideInput, uniform float amountInput, uniform float correlationInput, uniform float concentrationInput) : COLOR 
{ 	
	float3 guide = guideInput; 
    float amount = amountInput;
    float correlation = correlationInput;
    float concentration = concentrationInput;
	
	
	float4 color = tex2D (inputTexture , uv.xy);
	float3 input = float3 (color.r,color.g,color.b);
	
	
	float3 input_hsv = RGBtoHSV(input);
    float3 hue_pole1 = RGBtoHSV(guide);
    float3 hue_pole2 = HSVComplement(hue_pole1);
	
	float dist1 = abs(input_hsv.x - hue_pole1.x); if (dist1 > 0.5) dist1 = 1.0 - dist1;
    float dist2 = abs(input_hsv.x - hue_pole2.x); if (dist2 > 0.5) dist2 = 1.0 - dist2;
	
	float descent = smoothstep(0, correlation, input_hsv.y);
	
	float3 output_hsv = input_hsv;
	
	if(dist1 < dist2)
    {
        
        float c = descent * amount * (1.0 - pow((dist1 * 2.0), 1.0 / concentration));
        output_hsv.x = HueLerp(input_hsv.x, hue_pole1.x, c);
        output_hsv.y = lerp(input_hsv.y, hue_pole1.y, c);
    }
    else
    {
        
        float c = descent * amount * (1.0 - pow((dist2 * 2.0), 1.0 / concentration));
        output_hsv.x = HueLerp(input_hsv.x, hue_pole2.x, c);
        output_hsv.y = lerp(input_hsv.y, hue_pole2.y, c);
    }

	float3 output_rgb = HSVtoRGB(output_hsv);	
	
	float4 result_color = float4 (output_rgb.r,output_rgb.g,output_rgb.b,1.0);

	return result_color; 
}