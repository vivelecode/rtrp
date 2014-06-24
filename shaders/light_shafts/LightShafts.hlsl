







void main_vp(
    
	float4 iPosition	        : POSITION,
	
	out float4 oPosition		: POSITION,
	out float3 oPosition_       : TEXCOORD0,
	out float4 oUV    		    : TEXCOORD1,
	
	uniform float4x4 uWorld,
	uniform float4x4 uWorldViewProj,
	uniform float4x4 uTexViewProj)
{
	oPosition   = mul(uWorldViewProj, iPosition);
	float4 wPos = mul(uWorld, iPosition);
	oPosition_  = wPos.xyz;
	oUV         = mul(uTexViewProj, wPos);
}

void main_fp(
    
	float3 iPosition        : TEXCOORD0,
	float4 iUV    		    : TEXCOORD1,
	
	out float4 oColor		: COLOR,
	
	uniform float     uAttenuation,
	uniform float3    uLightPosition,
	uniform float     uLightFarClipDistance,
	uniform sampler2D uDepthMap  : register(s0),
	uniform sampler2D uCookieMap : register(s1),
	uniform sampler2D uNoiseMap	 : register(s2),
	uniform float Time)
{   
    iUV = iUV / iUV.w;
    
    float Depth  = tex2D(uDepthMap,  iUV.xy).r;
    
    if (Depth < saturate( length(iPosition-uLightPosition) / uLightFarClipDistance ))
    {
        oColor = float4(0,0,0,1);
    }
    else
    {
        float4 Cookie = tex2D(uCookieMap, iUV.xy);
        Time *= 0.0225;
        float2 Noise  = float2(tex2D(uNoiseMap,  iUV.xy - Time).r,
                               tex2D(uNoiseMap,  iUV.xy + Time).g);
    
        float noise  = Noise.x * Noise.y;
        float length_ = length(iPosition-uLightPosition)/uLightFarClipDistance;
        float atten  = 0.25 + 1/(length_*length_);
    
        oColor = float4(Cookie.rgb * Cookie.a * atten * uAttenuation * noise , 1);
    }
}



void main_vp_depth(
    
	float4 iPosition	        : POSITION,
	
	out float4 oPosition		: POSITION,
	out float3 oPosition_       : TEXCOORD0,
	
	uniform float4x4 uWorld,
	uniform float4x4 uWorldViewProj)
{
	oPosition   = mul(uWorldViewProj, iPosition);
	float4 wPos = mul(uWorld, iPosition);
	oPosition_  = wPos.xyz;
}

void main_fp_depth(
    
	float3 iPosition        : TEXCOORD0,
	
	out float4 oColor		: COLOR,
	
	uniform float3    uLightPosition,
	uniform float     uLightFarClipDistance)
{   
    float depth = saturate( length(iPosition-uLightPosition) / uLightFarClipDistance );
    
    oColor = float4(depth, depth, depth, 1);
}