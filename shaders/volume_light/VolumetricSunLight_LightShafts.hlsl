struct vertexInput
{ 
	float4				iPosition			: POSITION;
	float2				iTexCoord			: TEXCOORD0;	
};

struct vertexOutput 
{ 
	float4				oPosition			: POSITION;
	float2				oTexCoord			: TEXCOORD0;
};

vertexOutput main_vp(	vertexInput			IN,
						uniform float4x4	worldViewProj
					 )
{
	vertexOutput OUT;

	OUT.oPosition = mul(worldViewProj, IN.iPosition);
	OUT.oTexCoord = IN.iTexCoord;
	return OUT;
}

float4 main_fp(	vertexOutput		IN,
				uniform float3		screenLightPos,
				uniform float		weight,
				uniform float		decay,
				uniform float		exposure,
				uniform float		density,
				uniform sampler2D	frameLightTex				: register(s0)
			  )	:	COLOR
{

	float NUM_SAMPLES = 128;
	float2 texCoord = IN.oTexCoord;
	float2 deltaTexCoord = (texCoord - screenLightPos.xy) / NUM_SAMPLES;	
	deltaTexCoord *= density;



	
	float3 color = tex2D(frameLightTex, IN.oTexCoord.xy).rgb;				
	float illuminationDecay = 1.0;
	for( float i = 0.0; i < NUM_SAMPLES; i++ )								
	{
		texCoord -= deltaTexCoord;
		float3 sample = tex2D(frameLightTex, texCoord.xy).rgb;
		sample *= illuminationDecay * weight;
		color += sample;
		illuminationDecay *= decay;
	}
	return float4(color * exposure, 1.0);
}