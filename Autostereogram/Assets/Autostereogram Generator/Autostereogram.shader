Shader "Custom/AutostereogramShader"
{
    Properties
    {
        _Strip ("Previous Strip", 2D) = "white" {} 
        _CameraView ("Camera input", 2D) = "white" {}
        _StripWidth ("Strip Width", Float) = 1.0   
        _ScreenWidth ("Screen Width", Float) = 1920
        _DepthFactor ("Depth Factor", Float) = 1.0   
        _OffsetX ("Horizontal Offset", Float) = 0.0  
        _InvertDepth ("Invert Depth Map", Float) = -1.0 
        _DepthMode ("Depth Mode", Float) = -1.0
        _FlatMode ("Flatmode", Float) = 1.0
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _Strip;
            sampler2D _CameraView;
            sampler2D _CameraDepthTexture;
            float _DepthFactor;
            float _StripWidth;
            float _ScreenWidth;
            float _OffsetX;
            float _InvertDepth;
            float _DepthMode;
            float _FlatMode;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {   
                if ( _DepthMode == 1.0 )
                {
                    return tex2D(_CameraDepthTexture, i.uv);
                }

                float2 uv = i.uv;
                float2 offsetUV = uv;
                offsetUV.x = uv.x + _OffsetX;

                float stripStart = _OffsetX;
                float stripEnd = stripStart + _StripWidth / _ScreenWidth;
                float2 depth_uv = i.uv;
                depth_uv.x = lerp(stripStart, stripEnd, depth_uv.x);

                float depth = tex2D(_CameraDepthTexture, depth_uv).r;
                
                float displacement = 0.0;

                if ( _FlatMode == 1.0 )
                {
                    displacement = (depth > 0.0) ? _DepthFactor : 0.0;
                }
                else
                {
                    displacement = depth * _DepthFactor;
                }

                uv.x += displacement * _InvertDepth ;
                uv.x = frac(uv.x);

                fixed4 col = tex2D(_Strip, uv);
                
                // Debugging modes
                //col = tex2D(_CameraView, i.uv);

                return col;
            }
            ENDCG
        }
    }
    FallBack Off
}
