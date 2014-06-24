struct vertexInput
{ 
	float4				iPosition			: POSITION;
	float2				iTexCoord0			: TEXCOORD0;
};

struct vertexOutput 
{ 
	float4				oPosition			: POSITION;
	float2				oUv					: TEXCOORD0;
	float4				colour				: COLOR;
};

vertexOutput main_vp(	vertexInput			IN,
						uniform float4x4	worldViewProj,
						uniform float3	color
					 )
{
	vertexOutput OUT;
	OUT.oPosition = mul(worldViewProj, IN.iPosition);
	OUT.oUv = IN.iTexCoord0;
	OUT.colour = float4(color, 1.0);
	return OUT;
}