// Decompiled by fxopack (structure only; shader bodies not reconstructed)

#include "pbs_include.fxh"

// --- Samplers ---
sampler diffuseMapSampler = sampler_state
{
    Texture = diffuseMap;
    SamplerState = SamplerState : SS_FILTER_TAA_AUTO_ADDRESS_AUTO {};
};

sampler normalMapSampler = sampler_state
{
    Texture = normalMap;
    SamplerState = SamplerState : SS_FILTER_TAA_AUTO_ADDRESS_AUTO {};
};

sampler metallicGlossMapSampler = sampler_state
{
    Texture = metallicGlossMap;
    SamplerState = SamplerState : SS_FILTER_TAA_AUTO_ADDRESS_AUTO {};
};

sampler excludeMaskAndAOMapSampler = sampler_state
{
    Texture = excludeMaskAndAOMap;
    SamplerState = SamplerState : SS_FILTER_TAA_AUTO_ADDRESS_AUTO {};
};

sampler g_visTunnelObjectsSampler_state = sampler_state
{
    Texture = g_visTunnelObjectsTex;
    SamplerState = SamplerState {};
};

sampler metallicDetailMapSampler = sampler_state
{
    Texture = metallicDetailMap;
    SamplerState = SamplerState : SS_FILTER_AUTO_ADDRESS_WRAP {};
};

sampler g_defaultMicroDetailAtlasSampler = sampler_state
{
    Texture = g_defaultMicroDetailAtlas;
    SamplerState = SamplerState : SS_FILTER_LINEAR_ADDRESS_AUTO {};
};

sampler g_globalDirtNormalSmlSampler = sampler_state
{
    Texture = g_staticDirtNormalMap; 
    SamplerState = SamplerState {};
};

sampler camoEmissionMapSampler = sampler_state
{
    Texture = camoEmissionMap;
    SamplerState = SamplerState : SS_FILTER_LINEAR_ADDRESS_AUTO {};
};

sampler g_projectionDecalMap1Sampler = sampler_state
{
    Texture = g_projectionDecalMap1;
    SamplerState = SamplerState : SS_PROJECTION_DECALS {};
};

sampler g_projectionDecalGMMap1Sampler = sampler_state
{
    Texture = g_projectionDecalGMMap1;
    SamplerState = SamplerState : SS_PROJECTION_DECALS {};
};

sampler g_projectionDecal1EmissionMapSampler = sampler_state
{
    Texture = g_projectionDecal1EmissionMap;
    SamplerState = SamplerState : SS_FILTER_LINEAR_ADDRESS_AUTO {};
};

sampler g_projectionDecalMap2Sampler = sampler_state
{
    Texture = g_projectionDecalMap2;
    SamplerState = SamplerState : SS_PROJECTION_DECALS {};
};

sampler g_projectionDecalGMMap2Sampler = sampler_state
{
    Texture = g_projectionDecalGMMap2;
    SamplerState = SamplerState : SS_PROJECTION_DECALS {};
};

sampler g_projectionDecal2EmissionMapSampler = sampler_state
{
    Texture = g_projectionDecal2EmissionMap;
    SamplerState = SamplerState : SS_FILTER_LINEAR_ADDRESS_AUTO {};
};

sampler g_projectionDecalMap3Sampler = sampler_state
{
    Texture = g_projectionDecalMap3;
    SamplerState = SamplerState : SS_PROJECTION_DECALS {};
};

sampler g_projectionDecalGMMap3Sampler = sampler_state
{
    Texture = g_projectionDecalGMMap3;
    SamplerState = SamplerState : SS_PROJECTION_DECALS {};
};

sampler g_projectionDecal3EmissionMapSampler = sampler_state
{
    Texture = g_projectionDecal3EmissionMap;
    SamplerState = SamplerState : SS_FILTER_LINEAR_ADDRESS_AUTO {};
};

// --- Input / Output Structures ---
struct VS_INPUT
{
    float3 position       : POSITION;      // v0
    uint   normalPacked   : NORMAL_PACKED;  // v1.x (R8G8B8A8等でパックされた法線)
    uint   tangentPacked  : TANGENT_PACKED; // v2.x (接線)
    uint   binormalPacked : BINORMAL;       // v3.x (従法線)
    float2 texCoord       : TEXCOORD0;     // v4
};

struct VS_OUTPUT
{
    float4 position : SV_Position;      
    float2 texCoord : TEXCOORD0;        
    float3 worldNormal : NORMAL;        
    float3 worldBinormal : BINORMAL;    
    float3 worldTangent : TANGENT;      
    float4 worldPosAndTank : POSITION1; 
    float3 velocity : VELOCITY;         
    float4 decal1 : DECAL0;             
    float4 decal2 : DECAL1;             
    float4 decal3 : DECAL2;             
    float4 dummyOut : EXTRA_OUT;        
};

struct PS_OUTPUT
{
    float4 GBuffer0 : SV_Target0; 
    float4 GBuffer1 : SV_Target1; 
    float4 GBuffer2 : SV_Target2; 
    float4 GBuffer3 : SV_Target3; 
    float4 GBuffer4 : SV_Target4; 
};

// --- Helper Functions ---
static const float4 icb[8] = {
    float4(-1, 0, 0, 0),
    float4(0, -1, 0, 0),
    float4(0, 0, -1, 0),
    float4(0, 0, 0, -1),
    float4(1.0, 0, 0, 0),
    float4(0, -1.0, 1.0, 0),
    float4(-1.0, 0, 0, 0),
    float4(0, 1.0, -1.0, 0)
};

// 1バイトごとにパックされた法線/方向データを [-1, 1] の範囲に解凍する関数
float3 UnpackNormal(uint packed)
{
    float3 n;
    n.x = (float)(packed & 0xFF);
    n.y = (float)((packed >> 8) & 0xFF);
    n.z = (float)((packed >> 16) & 0xFF);
    // 1 / 127 = 0.0078740157... (パック時に 127倍されているデータを復元)
    return n * 0.007874f - 1.0f;
}

// クォータニオンから回転行列を生成し、デカール空間の投影テクスチャ座標と境界フェードを計算する関数
float4 ComputeDecal(float3 pos, float3 normal, float4 q, float4 posDoubleSided, float4 scaleMaxAngleCos)
{
    float3 decalPos = posDoubleSided.xyz;
    float3 scale = scaleMaxAngleCos.xyz;
    float maxAngleCos = scaleMaxAngleCos.w;
    float doubleSided = posDoubleSided.w;

    // クォータニオンから回転行列（直交基底）の生成
    float x2 = q.x * q.x; float y2 = q.y * q.y; float z2 = q.z * q.z;
    float xy = q.x * q.y; float xz = q.x * q.z; float yz = q.y * q.z;
    float wx = q.w * q.x; float wy = q.w * q.y; float wz = q.w * q.z;

    // 基底ベクトル (アセンブリのレジスタ配置を再現)
    float3 u = float3(1.0f - 2.0f * (y2 + z2), 2.0f * (xy - wz), 2.0f * (xz + wy));
    float3 v = -float3(2.0f * (xz - wy), 2.0f * (yz + wx), 1.0f - 2.0f * (x2 + y2));
    float3 w = float3(2.0f * (xy + wz), 1.0f - 2.0f * (x2 + z2), 2.0f * (yz - wx));

    // 投影空間へのトランスフォームとスケーリング
    float3 toProj = pos - decalPos;
    float3 localPos;
    localPos.x = dot(u, toProj) * (2.0f / scale.x);
    localPos.y = dot(v, toProj) * (2.0f / scale.z);
    localPos.z = dot(w, toProj) * (1.0f / scale.y);

    float4 result;
    // [-1, 1] から テクスチャUVの [0, 1] 範囲へマップ
    result.xy = localPos.xy * float2(0.5f, -0.5f) + 0.5f;
    result.z = localPos.z;

    // 法線とデカール方向による減衰
    float3 decalDir = normalize(w);
    float cosAngle = dot(-decalDir, normalize(normal));
    if (doubleSided > 0.0f)
    {
        cosAngle = abs(cosAngle);
    }
    
    // 角度が許容値（maxAngleCos）以内であれば 1.0、そうでなければ 0.0
    result.w = (cosAngle >= (1.0f - maxAngleCos)) ? 1.0f : 0.0f;

    return result;
}

// 頂点シェーダーメイン
VS_OUTPUT vs_main(VS_INPUT input)
{
    VS_OUTPUT output;

    // ワールド位置とクリップ座標の計算
    float3 worldPos = mul(float4(input.position, 1.0f), g_world).xyz;
    output.position = mul(float4(worldPos, 1.0f), g_jitteredViewProjMat);

    // 法線ベクトルの展開とワールド空間への変換
    float3 localNormal   = UnpackNormal(input.normalPacked);
    float3 localBinormal = UnpackNormal(input.binormalPacked);
    float3 localTangent  = UnpackNormal(input.tangentPacked);

    output.worldNormal   = normalize(mul(localNormal, (float3x3)g_world));
    output.worldBinormal = normalize(mul(localBinormal, (float3x3)g_world));
    output.worldTangent  = normalize(mul(localTangent, (float3x3)g_world));

    // 前フレームの座標計算と速度ベクトル（再投影マトリクス使用）
    float3 prevWorldPos = mul(float4(input.position, 1.0f), g_prevWorld).xyz;
    float3 reprojPos = mul(float4(prevWorldPos, 1.0f), g_reprojectionMat).xyz;
    output.velocity = g_writeGBufferVelocityBranch.x ? reprojPos : float3(0.0f, 0.0f, 0.0f);

    // プロジェクションデカールの処理
    output.decal1 = float4(0.0f, 0.0f, 0.0f, 0.0f);
    output.decal2 = float4(0.0f, 0.0f, 0.0f, 0.0f);
    output.decal3 = float4(0.0f, 0.0f, 0.0f, 0.0f);

    // 各デカールの有効・無効判定 (g_enabledProjectionDecalsCount に基づく)
    if (g_enabledProjectionDecalsCount.x > 0.0f)
    {
        output.decal1 = ComputeDecal(input.position, localNormal, g_projectionDecal1RotationQuaternion, g_projectionDecal1PosDoubleSided, g_projectionDecal1ScaleMaxAngleCos);
    }
    if (g_enabledProjectionDecalsCount.x > 1.0f)
    {
        output.decal2 = ComputeDecal(input.position, localNormal, g_projectionDecal2RotationQuaternion, g_projectionDecal2PosDoubleSided, g_projectionDecal2ScaleMaxAngleCos);
    }
    if (g_enabledProjectionDecalsCount.x > 2.0f)
    {
        output.decal3 = ComputeDecal(input.position, localNormal, g_projectionDecal3RotationQuaternion, g_projectionDecal3PosDoubleSided, g_projectionDecal3ScaleMaxAngleCos);
    }

    // タンク高さに基づくパラメータ算出（液面メーターやエフェクト用の比率と推測されます）
    output.worldPosAndTank.xyz = worldPos;
    float tankHeight = input.position.y + g_tankSize.z - g_tankSize.x;
    float tankRange  = g_tankSize.y - g_tankSize.x;
    output.worldPosAndTank.w = saturate(tankHeight / tankRange);

    output.dummyOut = float4(0.0f, 0.0f, 0.0f, 0.0f);
    output.texCoord = input.texCoord;

    return output;
}

float UnpackHalf(uint packedVal) {
    uint sign = (packedVal >> 15) & 0x00000001;
    uint exponent = (packedVal >> 10) & 0x0000001f;
    uint mantissa = packedVal & 0x000003ff;
    
    if (exponent == 0) {
        return 0.0;
    } else if (exponent == 31) {
        return sign ? -65504.0 : 65504.0; 
    }
    
    int realExp = (int)exponent - 15 + 127;
    uint res = (sign << 31) | (uint(realExp) << 23) | (mantissa << 13);
    return asfloat(res);
}

float3 permute(float3 x) {
    return frac(((x * 34.0) + 1.0) * x * (1.0 / 289.0)) * 289.0;
}

float NoiseGradient(float2 v) {
    const float4 C = float4(0.211324865405187,
                            0.366025403784439,
                           -0.577350269189626,
                            0.024390243902439);
    
    float2 i  = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);
    
    float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    
    i = i - floor(i * (1.0 / 289.0)) * 289.0;
    float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));
    
    float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;
    
    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;
    
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    
    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    
    return dot(m, g);
}

// --- Main Pixel Shader ---
PS_OUTPUT ps_main(VS_OUTPUT input, bool isFrontFace : SV_IsFrontFace)
{
    PS_OUTPUT output;

    // 0-4: 基本テクスチャサンプリング
    float4 baseMetallicGloss = tex2D(metallicGlossMapSampler, input.texCoord);
    float4 baseNormalRaw = tex2D(normalMapSampler, input.texCoord);
    
    float2 normalPack = (g_useNormalPackDXT1 != 0.0) ? baseNormalRaw.xz : baseNormalRaw.wx;
    float3 baseNormal;
    baseNormal.xy = normalPack * 2.0 - 1.0;
    baseNormal.z = sqrt(max(0.0, 1.0 - dot(baseNormal.xy, baseNormal.xy)));

    float4 albedoRaw = tex2D(diffuseMapSampler, input.texCoord);
    float4 excludeAO = tex2D(excludeMaskAndAOMapSampler, input.texCoord);

    // Alpha test
    float alphaRef = alphaReference.x * 0.003922;
    if (normalPack.y < alphaRef) {
        //discard;
    }

    // 15-58: VisTunnel (視界制限/近接フェード)
    float finalTunnelVal = 0.0;
    float noiseVal = 0.0;
    if (g_enableVisTunnel != 0.0 && g_visTunnelObjectsParams.enabled != 0.0) {
        float3 toCam = input.worldPosAndTank.xyz - g_lodCameraPos.xyz;
        float distToCam = length(toCam) * g_lodCameraPos.w;
        float normDist = saturate(distToCam / g_visTunnelObjectsParams.workingDistance);

        float aspect = min(g_screen.y / g_screen.x, g_visTunnelObjectsParams.maxAspectRatio); 
        float2 screenUV = input.position.xy * g_screen.zw / g_DRRParams.xy + float2(0.0, -0.5);

        float coneRadius = exp(log(1.0 - normDist) * g_visTunnelObjectsParams.opacityPower);
        coneRadius = coneRadius * g_visTunnelObjectsParams.nearConeRadius + g_visTunnelObjectsParams.farConeRadius;

        float2 tunnelUV = (screenUV / coneRadius) * float2(aspect, 1.0) + 0.5;
        float4 tunnelSample = tex2D(g_visTunnelObjectsSampler_state, tunnelUV);

        float tunnelFade = exp(log(tunnelSample.w) * g_visTunnelObjectsParams.screenSpaceFactor);
        tunnelFade = min(saturate(tunnelFade), 1.0);
        float minFade = max(g_visTunnelObjectsParams.minimumFade, 0.1);
        
        finalTunnelVal = max(normDist, max(minFade, tunnelFade));

        float ditherIndex = frac(g_time.z * g_TAAParams2.y);
        uint ditherIdx = (uint(ditherIndex) & 3) + 4;
        float ditherPattern = dot(icb[ditherIdx].xy, input.position.xy);
        float ditherPatternY = dot(icb[ditherIdx].zw, input.position.xy) * 0.569840;
        noiseVal = frac((ditherPattern * 0.754878 + ditherPatternY) + ditherIndex * 0.414214);

        if ((finalTunnelVal - noiseVal - 0.0001) < 0.0) {
            //discard; // カメラ接近時、不自然な貫通を防ぐためのクリップ
        }
    }

    // 59-297: Detail Mapping & Micro Details
    float2 detailUV = input.texCoord * g_detailUVTiling.xy;
    float4 detailSample = tex2D(metallicDetailMapSampler, detailUV);

    float3 camToPos = g_cameraPos.xyz - input.worldPosAndTank.xyz;
    float distToCamDetail = length(camToPos) * g_cameraPos.w;

    bool applyDetail = (g_useDetail) && (g_maxDetailDistance >= distToCamDetail);

    float microDetailNormalWeight = 0.0;
    float3 microNormal = float3(0.0, 0.0, 1.0);
    float3 r10_xy = float3(0, 1, 0); 
    float r8_y = 0.0;
    float r12_w = 0.5;

    if (applyDetail) {
        float mipIdx = min(floor(detailSample.z * 8.0 + 0.5), 7.0);
        float2 tiling = (g_defaultDetail != 0.0) ? g_detailUVTiling.xy : g_tilingRatio.xy;
        float2 rotatedUV = tiling * input.texCoord;
        
        uint packedA = g_detailParams[0].x;
        uint packedB = g_detailParams[0].y;
        
        float scaleRotA = UnpackHalf(packedA & 0xffff);
        float scaleRotB = UnpackHalf(packedB & 0xffff);
        
        float s, c;
        sincos(scaleRotA, s, c);
        
        float2 microUV1 = float2(dot(float2(c, -s), rotatedUV), dot(float2(s, c), rotatedUV));
        float4 microSample1 = tex2D(g_defaultMicroDetailAtlasSampler, microUV1);
        
        sincos(scaleRotB, s, c);
        float2 microUV2 = float2(dot(float2(c, -s), rotatedUV), dot(float2(s, c), rotatedUV));
        float4 microSample2 = tex2D(g_defaultMicroDetailAtlasSampler, microUV2);

        float metalCutoff = saturate(1.0 - g_detailMetallicCutoff.x);
        float detailMask = (packedA >> 16) & 0xff;
        microDetailNormalWeight = detailMask * 0.003922;

        float blendWeight = saturate((metalCutoff - 0.2 - (1.0 - baseMetallicGloss.y)) * 2.5);
        blendWeight = blendWeight * blendWeight * (3.0 - 2.0 * blendWeight);
        
        float2 rawMicroNormal = microSample1.xy * 2.0 - 1.0;
        microNormal.xy = rawMicroNormal * microDetailNormalWeight;
        microNormal.z = sqrt(max(0.0, 1.0 - dot(microNormal.xy, microNormal.xy)));
        
        r8_y = microDetailNormalWeight;
        r12_w = microSample2.w;
    }

    // 298-337: Wear & Metallic Wear Logic
    float currentMetallic = min(baseMetallicGloss.z, 0.9999);
    float wearFactor = excludeAO.y * excludeAO.y;
    wearFactor = wearFactor * wearFactor;
    
    if (g_useNewWear != 0.0) {
        // Wear（摩耗）処理
    } else {
        float numerator = currentMetallic - wearFactor * g_repaintMetallic.w;
        float denominator = 1.0 - wearFactor * g_repaintMetallic.w;
        currentMetallic = saturate(numerator / denominator);
    }

    // 法線とアルベド、ラフネスのブレンド
    float3 finalAlbedo = albedoRaw.rgb;
    float3 finalNormal = baseNormal;
    float finalRoughness = baseMetallicGloss.y;
    
    float3x3 TBN = float3x3(input.worldBinormal, input.worldTangent, input.worldNormal);
    if (applyDetail) {
        finalNormal = normalize(mul(microNormal, TBN));
    }

    // 388-463: Dirt & Wetness (汚れと濡れ表現)
    float2 dirtUV = float2(dot(input.texCoord, float2(0.866, -0.5)), dot(input.texCoord, float2(0.5, 0.866)));
    float4 dirtNormalSample = tex2D(g_globalDirtNormalSmlSampler, dirtUV);

    float wetness = g_dirtWetParams.w;
    float dynamicWet = lerp(wetness, saturate(wetness * 2.0 - 1.0), input.worldPosAndTank.w);
    
    float dirtAmount = saturate(g_dirtWetParams.y);
    float roughnessWet = lerp(finalRoughness, 0.1689, wetness);

    finalAlbedo = lerp(finalAlbedo, g_envDirtColor.rgb, dirtAmount * 0.5);
    finalRoughness = lerp(finalRoughness, roughnessWet, wetness);

    // 濡れによるアルベド色減衰率（r1.x）とラフネス変化（r6.x, r6.y）の厳密な計算
    float r1_x = -0.3 * dynamicWet + 1.0; 
    finalAlbedo = r1_x * finalAlbedo; // 濡れによる色暗化を正確に適用

    float r3_w = (-dirtAmount * 0.5 + 1.0) * 0.8 - finalRoughness;
    float r4_z = dynamicWet * dynamicWet;
    float r6_x = r4_z * r3_w + finalRoughness; // o0.y に入るラフネスX
    float r1_w_rough = -finalRoughness + 0.1689;
    float r6_y = dynamicWet * r1_w_rough + finalRoughness; // o0.x に入るラフネスY

    // Dissolve (ディゾルブ消滅効果)
    if (g_enableDissolve != 0.0) {
        float2 dissolveUV = input.texCoord * g_dissolveMapScale;
        float dissolveNoise = NoiseGradient(dissolveUV) * 65.0 + 0.5;
        
        float dissolveVal = dissolveNoise - g_dissolveFactor;
        if (dissolveVal < 0.0) {
            //discard;
        }

        if (dissolveVal < g_dissolveEdgeWidth) {
            float edgeLerp = saturate(dissolveVal / g_dissolveEdgeWidth);
            edgeLerp = edgeLerp * edgeLerp * edgeLerp;
            
            float3 edgeColor = g_dissolveEdgeColor.rgb;
            finalAlbedo = lerp(edgeColor, finalAlbedo, edgeLerp);
        }
    }

    // Projection Decals
    [unroll]
    for (uint i = 0; i < min(g_enabledProjectionDecalsCount, 3u); ++i) {
        float4 decalUV = (i == 0) ? input.decal1 : ((i == 1) ? input.decal2 : input.decal3);
        
        if (all(decalUV.xyz >= 0.0) && all(decalUV.xyz <= 1.0)) {
            float4 decalColor, decalGM, decalEmission;
            if (i == 0) {
                decalColor = tex2D(g_projectionDecalMap1Sampler, decalUV.xy);
                decalGM = tex2D(g_projectionDecalGMMap1Sampler, decalUV.xy);
                decalEmission = tex2D(g_projectionDecal1EmissionMapSampler, decalUV.xy);
            } else if (i == 1) {
                decalColor = tex2D(g_projectionDecalMap2Sampler, decalUV.xy);
                decalGM = tex2D(g_projectionDecalGMMap2Sampler, decalUV.xy);
                decalEmission = tex2D(g_projectionDecal2EmissionMapSampler, decalUV.xy);
            } else {
                decalColor = tex2D(g_projectionDecalMap3Sampler, decalUV.xy);
                decalGM = tex2D(g_projectionDecalGMMap3Sampler, decalUV.xy);
                decalEmission = tex2D(g_projectionDecal3EmissionMapSampler, decalUV.xy);
            }
            finalAlbedo = lerp(finalAlbedo, decalColor.rgb * g_projectionDecal1Tint.rgb, decalColor.a * g_projectionDecal1Tint.w);
        }
    }

    // GPU Decals Buffer 
    if (g_decalsBufferEnable != 0.0) {
        int2 screenPixel = int2(input.position.xy);
        float depthVal = g_decalsBufferDepth.Load(int3(screenPixel, 0)).x;
        uint4 decalMask = g_decalsBuffer3.Load(int3(screenPixel, 0));

        if (decalMask.x == g_gpuDecalsBlockIndex && depthVal >= input.position.z) {
            float4 decal0 = g_decalsBuffer0.Load(int3(screenPixel, 0));
            float4 decal1 = g_decalsBuffer1.Load(int3(screenPixel, 0));

            float3 decalNormal = decal1.xyz * 2.0 - 1.0;
            finalNormal = normalize(lerp(finalNormal, decalNormal, decal1.w));
            finalAlbedo = lerp(finalAlbedo, decal0.rgb, decal0.a);
        }
    }

    // G-Buffer への最終出力（アセンブリと完全にSwizzleを一致）
    float facingSign = isFrontFace ? 1.0 : -1.0;
    float3 worldNormalVec = finalNormal.x * input.worldBinormal 
                          + finalNormal.y * input.worldTangent 
                          + finalNormal.z * (input.worldNormal * facingSign);
    worldNormalVec = normalize(worldNormalVec);

    // GBuffer0 [o0]
    // x = r6.y (Wetness-modified Roughness Y)
    // y = r6.x (Wetness-modified Roughness X)
    // z = 0.0
    // w = Material ID
    float matID = (dynamicObject) ? ( applyOverlay ? 133.0 : 5.0 ) : ( applyOverlay ? 132.0 : 4.0 );
    output.GBuffer0 = float4(r6_y, r6_x, 0.0, matID * 0.003922);

    // GBuffer1 [o1]
    // xyz = ワールド法線
    // w = 1.0 - 環境遮蔽 (excludeAO.y)
    output.GBuffer1 = float4(worldNormalVec * 0.5 + 0.5, 1.0 - excludeAO.y);

    // GBuffer2 [o2]
    // xyz = 濡れ減衰が正しく乗算されたアルベド (finalAlbedo)
    // w = 0.0
    output.GBuffer2 = float4(finalAlbedo, 0.0);

    // GBuffer3 [o3]
    float2 projPos = input.velocity.xy / input.velocity.z;
    float2 velocityVec = input.position.xy * g_TAAParams.zw - projPos;
    output.GBuffer3 = (g_writeGBufferVelocityBranch) ? float4(velocityVec, 0.0, 0.0) : float4(0, 0, 0, 0);

    // GBuffer4 [o4]
    float3 emission = tex2D(camoEmissionMapSampler, input.texCoord).rgb * camoEmissionParams.x;
    // 537行目の金属摩耗（r2.w = currentMetallic）によるエミッション減衰を乗算
    emission = emission * currentMetallic; 
    output.GBuffer4 = float4(min(emission, 5.0) * 0.2, 0.0);

    return output;
}

technique Color < int renderType = 0; int channelType = 0; int skinned = 0; int instanced = 0; int dualUV = 0; >
{
    pass Main
    {
        RenderState = RenderState
        {
            BlendEnable = 0;
            SrcBlend = SRC_ALPHA;
            DestBlend = INV_SRC_ALPHA;
            BlendOp = ADD;
            SrcBlendAlpha = ONE;
            DestBlendAlpha = ONE;
            BlendOpAlpha = ADD;
            DepthAccess = READ_WRITE;   // <- likely: g_reverseDepthEnable, g_useSlopeScaledDepthBias  (2-way; unverified)
            DepthFunc = g_reverseDepthEnable ? GEQUAL : LEQUAL;
            CullMode = doubleSided ? CCW : NONE;
            FillMode = SOLID;
            StencilFunc = ALWAYS;
            StencilFail = KEEP;
            StencilDepthFail = KEEP;
            StencilPass = REPLACE;
            StencilRef = 136;
            StencilMask = 240;
            StencilWriteMask = 255;
            ColorWriteMask0 = ALL;
            ColorWriteMask1 = ALL;
            ColorWriteMask2 = ALL;
            ColorWriteMask3 = g_writeGBufferVelocity ? ALL : NONE;
            ColorWriteMask4 = RED | GREEN | BLUE;
            MultisampleEnable = 0;
            AlphaToCoverage = 0;
        };
        VertexShader = compile vs_5_0 vs_main();
        PixelShader = compile ps_5_0 ps_main();
    }
}

/*
technique ColorInstanced < int renderType = 0; int channelType = 0; int skinned = 0; int instanced = 1; int dualUV = 0; >
{
    pass Main
    {
        RenderState = RenderState
        {
            BlendEnable = 0;
            SrcBlend = ONE;
            DestBlend = ONE;
            BlendOp = ADD;
            SrcBlendAlpha = ONE;
            DestBlendAlpha = ONE;
            BlendOpAlpha = ADD;
            DepthAccess = READ_WRITE;   // <- likely: g_reverseDepthEnable, g_useSlopeScaledDepthBias  (2-way; unverified)
            DepthFunc = GEQUAL;   // <- selection-driven (4-way; no matching selection)
            CullMode = NONE;   // <- likely: doubleSided  (2-way; unverified)
            FillMode = WIREFRAME;   // <- likely: g_useWireFrame  (2-way; unverified)
            StencilFunc = ALWAYS;   // <- selection-driven (4-way; no matching selection)
            StencilFail = KEEP;
            StencilDepthFail = KEEP;
            StencilPass = REPLACE;   // <- likely: g_stencilUsageTerrain  (2-way; unverified)
            StencilRef = 136;   // <- selection-driven (4-way; no matching selection)
            StencilMask = 240;   // <- selection-driven (4-way; no matching selection)
            StencilWriteMask = 255;   // <- 3-way candidates: texAddressMode  (unverified)
            ColorWriteMask0 = ALL;   // <- 3-way candidates: texAddressMode  (unverified)
            ColorWriteMask1 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask2 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask3 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask4 = RED | GREEN | BLUE;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            MultisampleEnable = 0;
            AlphaToCoverage = 0;
        };
        VertexShader = compile vs_5_0 vs_placeholder();  // -> shader #1
        PixelShader = compile ps_5_0 ps_placeholder();  // -> shader #2
    }
}

technique EdgeDrawer < int renderType = 3; int channelType = 0; int skinned = 0; int instanced = 0; int dualUV = 0; >
{
    pass Main
    {
        RenderState = RenderState
        {
            BlendEnable = 0;
            SrcBlend = ONE;
            DestBlend = ONE;
            BlendOp = ADD;
            SrcBlendAlpha = ONE;
            DestBlendAlpha = ONE;
            BlendOpAlpha = ADD;
            DepthAccess = READ_WRITE;   // <- likely: g_reverseDepthEnable, g_useSlopeScaledDepthBias  (2-way; unverified)
            DepthFunc = GEQUAL;   // <- selection-driven (4-way; no matching selection)
            CullMode = CCW;   // <- likely: doubleSided  (2-way; unverified)
            FillMode = WIREFRAME;   // <- likely: g_useWireFrame  (2-way; unverified)
            StencilFunc = ALWAYS;   // <- selection-driven (4-way; no matching selection)
            StencilFail = KEEP;
            StencilDepthFail = KEEP;
            StencilPass = REPLACE;   // <- likely: g_stencilUsageTerrain  (2-way; unverified)
            StencilRef = 136;   // <- selection-driven (4-way; no matching selection)
            StencilMask = 240;   // <- selection-driven (4-way; no matching selection)
            StencilWriteMask = 255;   // <- 3-way candidates: texAddressMode  (unverified)
            ColorWriteMask0 = ALL;   // <- 3-way candidates: texAddressMode  (unverified)
            ColorWriteMask1 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask2 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask3 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask4 = RED | GREEN | BLUE;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            MultisampleEnable = 0;
            AlphaToCoverage = 0;
        };
        VertexShader = compile vs_5_0 vs_placeholder();  // -> shader #4
        PixelShader = compile ps_5_0 ps_placeholder();  // -> shader #3
    }
}

technique Shadow < int renderType = 1; int channelType = 0; int skinned = 0; int instanced = 0; int dualUV = 0; >
{
    pass Main
    {
        RenderState = RenderState
        {
            BlendEnable = 0;
            SrcBlend = ONE;
            DestBlend = ONE;
            BlendOp = ADD;
            SrcBlendAlpha = ONE;
            DestBlendAlpha = ONE;
            BlendOpAlpha = ADD;
            DepthAccess = READ_WRITE;   // <- likely: g_reverseDepthEnable, g_useSlopeScaledDepthBias  (2-way; unverified)
            DepthFunc = LEQUAL;   // <- selection-driven (4-way; no matching selection)
            CullMode = NONE;   // <- likely: doubleSided  (2-way; unverified)
            FillMode = WIREFRAME;   // <- likely: g_useWireFrame  (2-way; unverified)
            StencilFunc = ALWAYS;   // <- selection-driven (4-way; no matching selection)
            StencilFail = KEEP;
            StencilDepthFail = KEEP;
            StencilPass = REPLACE;   // <- likely: g_stencilUsageTerrain  (2-way; unverified)
            StencilRef = 136;   // <- selection-driven (4-way; no matching selection)
            StencilMask = 240;   // <- selection-driven (4-way; no matching selection)
            StencilWriteMask = 255;   // <- 3-way candidates: texAddressMode  (unverified)
            ColorWriteMask0 = ALL;   // <- 3-way candidates: texAddressMode  (unverified)
            ColorWriteMask1 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask2 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask3 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask4 = RED | GREEN | BLUE;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            MultisampleEnable = 0;
            AlphaToCoverage = 0;
        };
        VertexShader = compile vs_5_0 vs_placeholder();  // -> shader #6
        PixelShader = compile ps_5_0 ps_placeholder();  // -> shader #5
    }
}

technique ShadowInstanced < int renderType = 1; int channelType = 0; int skinned = 0; int instanced = 1; int dualUV = 0; >
{
    pass Main
    {
        RenderState = RenderState
        {
            BlendEnable = 0;
            SrcBlend = ONE;
            DestBlend = ONE;
            BlendOp = ADD;
            SrcBlendAlpha = ONE;
            DestBlendAlpha = ONE;
            BlendOpAlpha = ADD;
            DepthAccess = READ_WRITE;   // <- likely: g_reverseDepthEnable, g_useSlopeScaledDepthBias  (2-way; unverified)
            DepthFunc = LEQUAL;   // <- selection-driven (4-way; no matching selection)
            CullMode = NONE;   // <- likely: doubleSided  (2-way; unverified)
            FillMode = WIREFRAME;   // <- likely: g_useWireFrame  (2-way; unverified)
            StencilFunc = ALWAYS;   // <- selection-driven (4-way; no matching selection)
            StencilFail = KEEP;
            StencilDepthFail = KEEP;
            StencilPass = REPLACE;   // <- likely: g_stencilUsageTerrain  (2-way; unverified)
            StencilRef = 136;   // <- selection-driven (4-way; no matching selection)
            StencilMask = 240;   // <- selection-driven (4-way; no matching selection)
            StencilWriteMask = 255;   // <- 3-way candidates: texAddressMode  (unverified)
            ColorWriteMask0 = ALL;   // <- 3-way candidates: texAddressMode  (unverified)
            ColorWriteMask1 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask2 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask3 = ALL;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            ColorWriteMask4 = RED | GREEN | BLUE;   // <- likely: g_writeGBufferVelocity  (2-way; unverified)
            MultisampleEnable = 0;
            AlphaToCoverage = 0;
        };
        VertexShader = compile vs_5_0 vs_placeholder();  // -> shader #6
        PixelShader = compile ps_5_0 ps_placeholder();  // -> shader #7
    }
}
*/
