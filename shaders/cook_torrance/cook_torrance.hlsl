struct VS_INPUT
{
   float4 position : POSITION;
   float2 texCoord : TEXCOORD0;
   float3 normal   : NORMAL;
};

struct VS_OUTPUT
{
    float4 position : POSITION;
    float2 texCoord : TEXCOORD0;
	float3 l		: NORMAL0;
	float3 h		: NORMAL1;
	float3 n		: NORMAL2;
	float3 v		: NORMAL3;
	
};

struct PS_INPUT
{
    float4 position : POSITION;
    float2 texCoord : TEXCOORD0;
	float3 l		: NORMAL0;
    float3 h		: NORMAL1;
    float3 n		: NORMAL2;
    float3 v		: NORMAL3;
};


float4x4 	worldViewProj;
float4x4 	worldView;
float4   	lightPos;
float4   	eyePos;
float4x4 	inverseTransposeWorldView;

float 		r0;
float 		roughness;

void main_vp(in VS_INPUT input,  out VS_OUTPUT output)
{
 
   output.position = mul(worldViewProj, input.position);
   output.texCoord = input.texCoord;
      
   float3 p = mul(worldView,input.position).xyz;   
   output.l = normalize (lightPos.xyz  - p);   
   output.v = normalize (eyePos.xyz  - p);       
   output.h = normalize ( output.l + output.v );        
   output.n = normalize ( mul( (float3x3)inverseTransposeWorldView, input.normal) );     
}

 
float4 main_fp(PS_INPUT input): COLOR0
{	
		float4  diffColor = float4 ( 0.252, 0.252, 0.252, 1.0 );
		float4  specColor = float4 ( 0.288, 0.252, 0.233, 1.0 );
		
		float e         = 2.7182818284;
		float pi        = 3.1415926;
		
		float3  n2   = normalize ( input.n );
		float3  l2   = normalize ( input.l );
		float3  v2   = normalize ( input.v );
		float3  h2   = normalize ( input.h );
		float nh   = dot ( n2, h2 );
		float nv   = dot ( n2, v2 );
		float nl   = dot ( n2, l2 );		
			
		float r2   = roughness * roughness;
		float nh2  = nh * nh;
		float ex   = - (1.0 - nh2)/(nh2 * r2);
		float d    = pow ( e, ex ) / (r2*nh2*nh2);	

	
		float f    = lerp ( pow ( 1.0 - nv, 5.0 ), 1.0, r0 );
		
		
		float x    = 2.0 * nh / dot ( v2, h2 );
		float g    = min ( 1.0, min ( x * nl, x * nv ) );			
		float ct   = d*f*g / nv;	

		float4  diff = diffColor * max ( 0.0, nl );
		float4  spec = specColor * max ( 0.0, ct );		
			
			
		return (diff + spec);
}
