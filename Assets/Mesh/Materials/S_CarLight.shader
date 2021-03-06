// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:False,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:4013,x:32719,y:32712,varname:node_4013,prsc:2|emission-8040-OUT,alpha-1355-OUT;n:type:ShaderForge.SFN_VertexColor,id:9089,x:31916,y:32609,varname:node_9089,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6246,x:32371,y:32801,varname:node_6246,prsc:2|A-9089-R,B-4103-OUT;n:type:ShaderForge.SFN_Multiply,id:8040,x:32479,y:32580,varname:node_8040,prsc:2|A-9089-RGB,B-8914-OUT;n:type:ShaderForge.SFN_Slider,id:8914,x:32110,y:32533,ptovrint:False,ptlb:Emissive,ptin:_Emissive,varname:node_8914,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:10;n:type:ShaderForge.SFN_Slider,id:4103,x:32048,y:32902,ptovrint:False,ptlb:Opacity,ptin:_Opacity,varname:_Emissive_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:10;n:type:ShaderForge.SFN_Fresnel,id:2778,x:32126,y:33015,varname:node_2778,prsc:2|EXP-6347-OUT;n:type:ShaderForge.SFN_Multiply,id:1355,x:32545,y:32980,varname:node_1355,prsc:2|A-6246-OUT,B-1098-OUT;n:type:ShaderForge.SFN_OneMinus,id:1098,x:32310,y:33015,varname:node_1098,prsc:2|IN-2778-OUT;n:type:ShaderForge.SFN_Slider,id:6347,x:31805,y:33144,ptovrint:False,ptlb:Fresnel_Exp,ptin:_Fresnel_Exp,varname:_Opacity_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:10;proporder:8914-4103-6347;pass:END;sub:END;*/

Shader "Shader Forge/S_CarLight" {
    Properties {
        _Emissive ("Emissive", Range(0, 10)) = 0
        _Opacity ("Opacity", Range(0, 10)) = 0
        _Fresnel_Exp ("Fresnel_Exp", Range(0, 10)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float _Emissive;
            uniform float _Opacity;
            uniform float _Fresnel_Exp;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float4 vertexColor : COLOR;
                UNITY_FOG_COORDS(2)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float3 emissive = (i.vertexColor.rgb*_Emissive);
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,((i.vertexColor.r*_Opacity)*(1.0 - pow(1.0-max(0,dot(normalDirection, viewDirection)),_Fresnel_Exp))));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
