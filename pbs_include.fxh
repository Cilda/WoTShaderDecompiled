struct FogParams
{
    float4 m_densityHeightFalloffDistance;
    float4 m_colorEdgeFog;
    float4 m_scatterColorSunExp;
    float4 m_outerBB;
    float4 m_innerBB;
    float4 m_scatterStartEnabled;
};

struct VFogParams
{
    float fogStart;
    float fogDistance;
    uint fogTextureDepth;
    uint fogEnabled;
    float curveCConst;
    float curvePConst;
};

struct WindParamsPack
{
    float4 p0;
    float4 p1;
};

struct SunLight
{
    float4 m_color;
    float4 m_ambient;
    float4 m_ambientTint;
    float3 m_dir;
};

struct VisibilityTunnelParams
{
    float workingDistance;
    float screenSpaceFactor;
    float nearConeRadius;
    float farConeRadius;
    float opacityPower;
    float maxAspectRatio;
    float minimumFade;
    int enabled;
};

struct AtlasDesc
{
    float4 bound;
    float4 grid;
    float4 tex;
};

struct SimplifiedDeferredParams
{
    float terrainBakedShadowFactor;
    float bakedAOToShadowsMult;
    float bakedAOPower;
    float vegetationMetallicMult;
    float transmissionMult;
    float simplifiedRenderer;
    float waterReflectionAttenuation;
};

struct PointLight
{
    float4 position;
    float4 colour;
    float4 lightmaskParams;
};

struct SpotLight
{
    float4 position;
    float4 colour;
    float4 attenuation;
    float4 orientation;
    float4 lightmaskParams;
};

shared ubuffer PerFrame
{
    float g_sunVisibility : SunVisibility;
    int g_lightingQuality : LightingQuality;
    bool g_writeGBufferVelocityBranch : WriteGBufferVelocityBranch;
    bool g_decalsBufferEnable : DecalsBufferEnable;
    float4 g_textureQuality : TextureQuality;
    float4 g_time : Time;
    float4 g_TAAParams : TAAParams;
    float4x4 g_reprojectionMat : ReprojectionMat;
    float4 g_DRRParams : DRRParams;
    float4 g_localFogForwardParams : LocalFogForwardParams;
    float4 g_localFogForwardEnable : LocalFogForwardEnable;
    FogParams g_fogParams : FogParams;
    VFogParams g_volumetricFogParams : VolumetricFogParams;
    WindParamsPack g_windParams : WindParams;
    float4 g_HDRParams : HDRParams;
    float4 g_envLumMultipliers : EnvLumMultipliers;
    float4 g_gammaCorrection : GammaCorrection;
    float4 g_shadowBlendParams : ShadowBlendParams;
    float4 g_asmParams : AsmParams;
    float4 g_specularParams : SpecularParams;
    float4 g_PMREMMipsNumber : PMREMMipsNumber;
    float4 g_flakesParams : FlakesParams;
    float4 g_SSRparams : SSRparams;
    float4x4 g_SSAOParams : SSAOParams;
    SunLight g_sunLight : SunLight;
    float4 g_particlesParams : ParticlesParams;
    float g_maxDetailDistance : MaxDetailDistance;
    VisibilityTunnelParams g_visTunnelParticlesParams : VisibilityTunnelParticlesParams;
    VisibilityTunnelParams g_visTunnelObjectsParams : VisibilityTunnelObjectsParams;
    float4 g_shGridSize : SHGridSize;
    float g_shGridFade : SHGridFade;
    float4 g_sh9 : REM_SH9;
    float4 g_remSHParams : REM_SH_PARAMS;
    float4 g_envDirtColor : DirtColor;
    float4x4 g_forceFieldMatrix : ForceFieldMatrix;
    float4x4 g_forceFieldPrevMatrix : ForceFieldPrevMatrix;
    AtlasDesc g_atlasDescHM : TerrainAtlasDescHM;
    float4 g_worldXZBounds : WorldXZBounds;
    float4 g_clusterShadingParams : ClusterShadingParams;
    SimplifiedDeferredParams g_simplifiedDeferredParams : SimplifiedDeferredParams;
    float4 g_TAAParams2 : TAAParams2;
};

shared ubuffer PerScreen
{
    float4 g_screen : Screen;
};

shared ubuffer PerView
{
    float4x4 g_viewMat : View;
    float4x4 g_invViewMat : InvView;
    float4x4 g_projMat : Projection;
    float4x4 g_viewProjMat : ViewProjection;
    float4x4 g_invViewProjMat : InvViewProjection;
    float4x4 g_lastViewProjMat : LastViewProjection;
    float4x4 g_jitteredViewProjMat : JitteredViewProjection;
    float4x4 g_jitteredProjMat : JitteredProjection;
    float4x4 g_environmentMat : EnvironmentTransform;
    float4x4 g_cameraDirsWS : CameraDirsWS;
    float4x4 g_cameraDirsVS : CameraDirsVS;
    float4x4 g_asmDistantIndexTexMat : AsmDistantIndexTexMat;
    float4x4 g_asmIndexTexMat : AsmIndexTexMat;
    float4x4 g_asmInvDistantIndexTexMat : AsmInvDistantIndexTexMat;
    float4x4 g_asmInvIndexTexMat : AsmInvIndexTexMat;
    float4x4 g_worldReconstructionMat : WorldReconstructionMat;
    float4 g_fogParamsView : FogParamsView;
    float4 g_cameraPos : CameraPos;
    float4 g_lastCameraPos : LastCameraPos;
    float4 g_lodCameraPos : LodCameraPos;
    float3 g_cameraDir : CameraDir;
    float4 g_farNearPlane : FarNearPlanes;
    float4 g_farPlane : FarPlane;
    float4 g_shadowAlgoParams : ShadowAlgoParams;
    float4 g_clipPlane : ClipPlane;
    bool g_clipPlaneEnable : ClipPlaneEnable;
};

ubuffer PerObject
{
    PointLight g_globalOmniLights : GlobalOmniLights;
    SpotLight g_globalSpotLights : GlobalSpotLights;
};

// --- loose global constants ($Globals) ---
float2 g_FSQuadTCAdjust;
bool dynamicObject < int exposed = 1; string name = "Dynamic Object"; string desc = "Whether this material should be treated as part of a dynamic object or not"; string groupName = "Material Settings.Params"; >;
bool applyOverlay < string name = "Apply overlay material"; string groupName = "Material Settings.Params"; >;
float4x4 g_world : World;
float4x4 g_prevWorld : PrevWorld;
float4x4 g_instancingStream : InstancingStream;
int alphaReference < int exposed = 1; string name = "Reference Value"; string desc = "The alpha value cut-off value"; string groupName = "Material Settings.Alpha Test"; float4 range = {0, 255, 1, 0}; >;
bool g_useNormalPackDXT1 < int exposed = 1; string name = "Use Normal Map DXT1"; string groupName = "Material Settings.Params"; >;
bool g_useNMCamoTexture < int exposed = 1; string name = "Use Normal camouflage texture"; string groupName = "Repaint Settings.Camouflage Normal"; >;
bool g_useNewWear < int exposed = 1; string Name = "Use new wear"; string GroupName = "Repaint Settings"; >;
float4 g_baseColor < int exposed = 1; string name = "Base tank nation color"; string control = "ColorPicker"; string groupName = "Repaint Settings"; >;
float4 g_repaintColor1 < int exposed = 1; string name = "Repaint color 1"; string control = "ColorPicker"; string groupName = "Repaint Settings"; >;
float4 g_repaintColor2 < int exposed = 1; string name = "Repaint color 2"; string control = "ColorPicker"; string groupName = "Repaint Settings"; >;
float4 g_repaintColor3 < int exposed = 1; string name = "Repaint color 3"; string control = "ColorPicker"; string groupName = "Repaint Settings"; >;
float4 g_repaintMetallic < int exposed = 1; string name = "Repaint metallic"; string desc = "x - region1, y - region2, z - region3, w - repaint strength (UI TODO)"; string groupName = "Repaint Settings"; >;
float4 g_repaintGloss < int exposed = 1; string name = "Repaint gloss"; string desc = "x - region1, y - region2, z - region3, w - repaint fading (UI TODO)"; string groupName = "Repaint Settings"; >;
float4 camoEmissionParams < int exposed = 1; string xName = "Emission Deferred Power"; string yName = "Emission Forward Power"; string groupName = "Repaint Settings.Emission Settings"; string control = "Slider"; float4 xyRange = {0, 10, 0.1, 2}; >;
float g_ditherCoeff < int exposed = 1; string Name = "Dithering coefficient"; string GroupName = "Dithering"; float4 range = {0, 100, 1, 1}; >;
bool g_enableVisTunnel < int exposed = 0; string name = "Enable Visibility Tunnel"; string groupName = "Visibility Tunnel"; >;
int g_enabledProjectionDecalsCount < int exposed = 1; string name = "Enabled decals count"; string groupName = "Decals Settings"; >;
float4 g_projectionDecal1Tint < int exposed = 1; string name = "Tint Color"; string groupName = "Decals Settings.Decal 1"; string control = "ColorPicker"; string alphaMode = "None"; >;
float4 g_projectionDecal1PosDoubleSided < int exposed = 1; string name = "Position (x, y, z) / Double Sided (w - 0 or 1)"; string desc = "Decal position in object space"; string groupName = "Decals Settings.Decal 1"; >;
float4 g_projectionDecal1ScaleMaxAngleCos < int exposed = 1; string name = "Scale (x, y, z) / Max Angle Cosine (w)"; string desc = "Decal scale in decals local space / Cosine of max angle that allows projection"; string groupName = "Decals Settings.Decal 1"; >;
float4 g_projectionDecal1RotationQuaternion < int exposed = 1; string name = "Rotation"; string desc = "Decal rotation quaternion"; string groupName = "Decals Settings.Decal 1"; >;
float4 g_projectionDecal1EmissionParams < int exposed = 1; string xName = "Emission Deferred Power"; string yName = "Emission Forward Power"; string groupName = "Decals Settings.Decal 1.Emission Settings"; string control = "Slider"; float4 xyRange = {0, 10, 0.1, 2}; >;
float4 g_projectionDecal2Tint < int exposed = 1; string name = "Tint Color"; string groupName = "Decals Settings.Decal 2"; string control = "ColorPicker"; string alphaMode = "None"; >;
float4 g_projectionDecal2PosDoubleSided < int exposed = 1; string name = "Position (x, y, z) / Double Sided (w - 0 or 1)"; string desc = "Decal position in object space"; string groupName = "Decals Settings.Decal 2"; >;
float4 g_projectionDecal2ScaleMaxAngleCos < int exposed = 1; string name = "Scale (x, y, z) / Max Angle Cosine (w)"; string desc = "Decal scale in decals local space / Cosine of max angle that allows projection"; string groupName = "Decals Settings.Decal 2"; >;
float4 g_projectionDecal2RotationQuaternion < int exposed = 1; string name = "Rotation"; string desc = "Decal rotation quaternion"; string groupName = "Decals Settings.Decal 2"; >;
float4 g_projectionDecal2EmissionParams < int exposed = 1; string xName = "Emission Deferred Power"; string yName = "Emission Forward Power"; string groupName = "Decals Settings.Decal 2.Emission Settings"; string control = "Slider"; float4 xyRange = {0, 10, 0.1, 2}; >;
float4 g_projectionDecal3Tint < int exposed = 1; string name = "Tint Color"; string groupName = "Decals Settings.Decal 3"; string control = "ColorPicker"; string alphaMode = "None"; >;
float4 g_projectionDecal3PosDoubleSided < int exposed = 1; string name = "Position (x, y, z) / Double Sided (w - 0 or 1)"; string desc = "Decal position in object space"; string groupName = "Decals Settings.Decal 3"; >;
float4 g_projectionDecal3ScaleMaxAngleCos < int exposed = 1; string name = "Scale (x, y, z) / Max Angle Cosine (w)"; string desc = "Decal scale in decals local space / Cosine of max angle that allows projection"; string groupName = "Decals Settings.Decal 3"; >;
float4 g_projectionDecal3RotationQuaternion < int exposed = 1; string name = "Rotation"; string desc = "Decal rotation quaternion"; string groupName = "Decals Settings.Decal 3"; >;
float4 g_projectionDecal3EmissionParams < int exposed = 1; string xName = "Emission Deferred Power"; string yName = "Emission Forward Power"; string groupName = "Decals Settings.Decal 3.Emission Settings"; string control = "Slider"; float4 xyRange = {0, 10, 0.1, 2}; >;
uint g_gpuDecalsBlockIndex < int exposedRuntime = 1; >;
uint g_gpuDecalsBlockCapacity < int exposedRuntime = 1; >;
float g_gpuDecalsClusterizationFarPlane < int exposedRuntime = 1; >;
bool g_enableDissolve < int exposed = 1; string name = "Enable"; string groupName = "Dissolve"; >;
float g_dissolveFactor < int exposed = 1; string name = "Factor"; string groupName = "Dissolve"; string control = "Slider"; float4 range = {0, 1, 0.01, 2}; >;
float g_dissolveEdgeWidth < int exposed = 1; string name = "Edge Width"; string groupName = "Dissolve"; string control = "Slider"; float4 range = {0, 1, 0.01, 2}; >;
float4 g_dissolveEdgeColor < int exposed = 1; string name = "Edge Color"; string groupName = "Dissolve"; string control = "ColorPicker"; >;
bool g_edgeGradient < int exposed = 1; string name = "Edge Gradient"; string groupName = "Dissolve"; >;
float g_dissolveMapScale < int exposed = 1; string name = "UV Scale"; string groupName = "Dissolve"; string control = "Slider"; float4 range = {0, 50, 0.01, 2}; >;
float g_edgeDrawerData < int exposedRuntime = 1; >;
float g_heatPercentage < int exposed = 1; string name = "Debug overheat percentage"; string desc = "Part temperature / Max part temperature"; string groupName = "Overheating Mechanic"; string control = "Slider"; float4 range = {0, 1, 0.01, 2}; >;
float g_heatEmissionCoefficient < int exposed = 1; string name = "Heat emission coefficient"; string groupName = "Overheating Mechanic"; string control = "Slider"; float4 range = {0, 20, 0.5, 2}; >;
float4 g_detailUVTiling < int exposed = 1; string name = "Metallic Detail Map UV"; string desc = "Metallic Detail Map uv tiling"; string groupName = "Detail Settings"; float4 range = {1, 100, 0.01, 3}; >;
bool g_useDetail < int exposed = 1; string name = "Enable"; string groupName = "Micro Details Settings"; >;
bool g_defaultDetail < int exposed = 1; string name = "No ID Map"; string groupName = "Micro Details Settings"; >;
float g_metallicDetailInfluence < int exposed = 1; string name = "Metallic Detail Strength"; string desc = "The detail map strength for metallic"; string groupName = "Detail Settings"; string control = "Slider"; float4 range = {0, 1, 0.01, 2}; >;
float4 g_tankSize < int exposed = 1; string xName = "Tank Size Min"; string yName = "Tank Size Max"; string zName = "Tank Size Offset"; string groupName = "Dirt Settings"; float4 range = {0, 100, 0.01, 2}; >;
float4 g_dirtWetParams < int exposed = 1; string xName = "Wet Dirt Level Start"; string yName = "Wet Dirt Level End"; string zName = "Wet Level"; string wName = "Wet Strength"; string groupName = "Dirt Settings"; >;
float g_waterLevelWS < int exposed = 1; string name = "Water level WS"; string groupName = "Dirt Settings"; >;
float g_detailMetallicCutoff < int exposed = 1; string name = "Metallic Limit"; string groupName = "Micro Details Settings"; string control = "Slider"; float4 range = {0, 1, 0.01, 2}; >;
float2 g_tilingRatio < int exposed = 1; string name = "Detail UV Tiling"; string groupName = "Micro Details Settings"; float4 range = {0, 1, 0.01, 2}; >;
float g_glossMin < int exposed = 1; string name = "Detail Mask/Detail Mask Lower Clamp"; string groupName = "Micro Details Settings"; string control = "RangeSlider"; float4 range = {0, 1, 0.01, 2}; >;
float g_glossMax < int exposed = 1; string name = "Detail Mask/Detail Mask Upper Clamp"; string groupName = "Micro Details Settings"; string control = "RangeSlider"; float4 range = {0, 1, 0.01, 2}; >;
float g_dirtLevel < int exposed = 1; string name = "Dirt Level"; string groupName = "Micro Details Settings"; string control = "Slider"; float4 range = {0, 1, 0.01, 2}; >;
uint4x4 g_detailParams < int exposed = 1; string name = "Detail Params"; string groupName = "Micro Details Settings"; >;

// --- selection variables ($Selection); the default value and
// allowed-value list are not stored in the .fxo ---
selection bool g_reverseDepthEnable : ReverseDepthEnabled = false : [true, false];
selection bool g_writeGBufferVelocity : WriteGBufferVelocity = false : [true, false];
selection int g_shadowAlgo : ShadowAlgo = 0 : [0];
selection TexFilterType g_mipFilter : MipFilter = LINEAR : [LINEAR];
selection TexFilterType g_minMagFilter : MinMagFilter = LINEAR : [LINEAR];
selection int g_maxAnisotropy : MaxAnisotropy = 1 : [1];
selection int g_mipMapLodBias : MipMapLodBias = 0 : [0];
selection StateColorMask g_shadowColorWriteMask : ShadowColorWriteMask = ALL : [ALL];
selection bool g_useSlopeScaledDepthBias : UseSlopeScaledDepthBias = false : [true, false];
selection bool g_useWireFrame : UseWireFrame = false : [true, false];
selection bool g_gpuDecalsEnable : GpuDecalsEnable = false : [true, false];
selection bool doubleSided < int exposed = 1; string name = "Double Sided"; string desc = "Whether the material is draw on both sides"; string groupName = "Material Settings.Params"; > = false : [true, false];
selection int srcBlend < int exposed = 1; string name = "Source Blend"; string desc = "D3D Source blend factor for blending with backbuffer"; string groupName = "Material Settings.Blend"; string control = "ComboBox"; string values = "('ZERO', 1);
('ONE', 2);
('SRCCOLOR', 3);
('INVSRCCOLOR', 4);
('SRCALPHA', 5);
('INVSRCALPHA', 6);
('DESTALPHA', 7);
('INVDESTALPHA', 8);
('DESTCOLOR', 9);
('INVDESTCOLOR', 10);
('SRCALPHASAT', 11);"; > = 5 : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
selection int destBlend < int exposed = 1; string name = "Destination Blend"; string desc = "D3D Destination blend factor for blending with backbuffer"; string groupName = "Material Settings.Blend"; string control = "ComboBox"; string values = "('ZERO', 1);
('ONE', 2);
('SRCCOLOR', 3);
('INVSRCCOLOR', 4);
('SRCALPHA', 5);
('INVSRCALPHA', 6);
('DESTALPHA', 7);
('INVDESTALPHA', 8);
('DESTCOLOR', 9);
('INVDESTCOLOR', 10);
('SRCALPHASAT', 11);"; > = 6 : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
selection int texAddressMode < int exposed = 1; string name = "Texture Address Mode"; string desc = "D3D Texture Address Mode"; string groupName = "Material Settings.Shading"; string control = "ComboBox"; string values = "('Wrap', 1);
('Mirror', 2);
('Clamp', 3);"; > = 1 : [1, 2, 3];
selection bool alphaTestEnable < int exposed = 1; string name = "Enable"; string desc = "Whether an alpha test should be performed"; string groupName = "Material Settings.Alpha Test"; > = false : [true, false];
selection bool g_useRepaint < int exposed = 1; string name = "Enable"; string groupName = "Repaint Settings"; > = false : [true, false];
selection bool g_useOldCamoDetail < int exposed = 1; string name = "Use old camo detail"; string groupName = "Repaint Settings"; > = false : [true, false];
selection bool g_useGMCamoTexture < int exposed = 1; string name = "Use Gloss/Metallic camouflage texture"; string desc = "false - use specified glossCamo and metallicCamo values per channel, true - use texture"; string groupName = "Repaint Settings"; > = false : [true, false];
selection int g_edgeDrawerMode < int exposedRuntime = 1; > = 0 : [0];
selection bool g_stencilUsageTerrain = true : [true, false];
selection bool g_useBias < int exposed = 1; > = false : [true, false];
selection bool g_useOverheatMechanic < int exposed = 1; string name = "Use overheat Mechanic"; string groupName = "Overheating Mechanic"; > = false : [true, false];
selection bool g_useDetailMetallic < int exposed = 1; string name = "Use Detail Metallic"; string desc = "Use detail metallic map for apropriate tanks"; string groupName = "Detail Settings"; > = false : [true, false];
selection bool g_usePreciseEdge = false : [true, false];
selection bool g_enableDirt < int exposed = 1; string name = "Enable"; string groupName = "Dirt Settings"; > = false : [true, false];
selection bool g_isChassis < int exposed = 1; string name = "Is Chassis"; string groupName = "Dirt Settings"; > = false : [true, false];

Texture2D g_GBufferChannel0 : GBufferChannel0;
Texture2D g_GBufferChannel1 : GBufferChannel1;
Texture2D g_GBufferChannel2 : GBufferChannel2;
Texture2D g_GBufferChannel3 : GBufferChannel3;
Texture2D g_GBufferChannel4 : GBufferChannel4;
texture g_PMREM : PMREM;
texture g_EnvBRDFLut : EnvBRDFLut;
texture g_normalsGGXRough : NormalsGGXRough;
Texture2D g_hierarchicalZMap : HierarchicalZMap;
texture g_staticDirtNormalMap : StaticDirtNormal;
texture g_hammersleyLUT : HammersleyLUT;
texture g_noiseMap : NoiseMap;
texture g_bitwiseLUTMap : BitwiseLUTMap;
texture g_speedTreeMaterialsMap : SpeedTreeMaterials;
texture g_speedTreePropertyAtlas : SpeedTreeProperties;
texture g_ssShadowMap : ShadowScreenSpaceMap;
texture g_depthBasedEffectsTexture : DepthBasedEffectsTexture;
texture g_SSRMap : SSRmap;
texture g_SSRSourceMap : SSRSourcemap;
Texture2D g_decalsBuffer0 : DecalsBuffer0;
Texture2D g_decalsBuffer1 : DecalsBuffer1;
Texture2D g_decalsBuffer2 : DecalsBuffer2;
Texture2D g_decalsBuffer3 : DecalsBuffer3;
Texture2D g_decalsBufferDepth : DecalsBufferDepth;
Texture2DArray g_gpuDecalsGradientsAtlas : GpuDecalsGradients;
Texture2DArray g_defaultMicroDetailAtlas : DefaultMicroDetailAtlas;
Texture2D g_ditherTexture : DitherTexture;
Texture2D g_moments : OITMoments;
Texture2D g_opticalDepth : OITOpticalDepth;
Texture3D g_volumetricFogTexture : VolumetricFogTexture;
Texture2D g_asmIndexTexture : AsmIndexTexture;
Texture2D g_asmDistantIndexTexture : AsmDistantIndexTexture;
Texture2D g_asmDemTexture : AsmDemTexture;
Texture2D g_asmDepthAtlasTexture : AsmDepthAtlasTexture;
Texture2D g_vsmDepthAtlasTexture : VsmDepthAtlasTexture;
Texture3D g_shGrid3D : SHGrid;
Texture3D g_localLightsFrustum : LocalLightsFrustum;
StructuredBuffer g_lightIndexList : LightIndexList;
texture g_forceFieldTexture : ForceFieldTexture;
texture g_forceFieldPrevTexture : ForceFieldPrevTexture;
Texture2D g_atlasTilesHM : TerrainAtlasHM;
Texture2D g_atlasIndirectHM : TerrainAtlasIndirectHM;
Texture2D g_lastFrameAvgLumMap : LastFrameAvgLumMap;
Texture2D g_visTunnelParticlesTex : VisibilityTunnelParticlesTexture;
Texture2D g_visTunnelObjectsTex : VisibilityTunnelObjectsTexture;
Texture2DArray g_lightMaskTexture2DArray : LightMaskTexture2DArray;
Texture2D diffuseMap < int exposed = 1; string name = "Albedo Map"; string desc = "The albedo map for the material"; string groupName = "Texture Maps"; string fileFilter = "*_AM.png;*_AM.tga;*_AM.dds;*_BAM.dds"; >;
Texture2D normalMap < int exposed = 1; string name = "Normal Map"; string desc = "The normal map for the material"; string groupName = "Texture Maps"; string autoValue = "{diffuseMap}_ANM;{diffuseMap}_NM"; string fileFilter = "*_ANM.png;*_ANM.tga;*_ANM.dds;*_BANM.dds;*_NM.tga"; >;
Texture2D metallicGlossMap < int exposed = 1; string name = "Metallic and Gloss Map"; string desc = "The metallic and gloss map for the material"; string groupName = "Texture Maps"; string autoValue = "{diffuseMap}_GMM"; string fileFilter = "*_GMM.png;*_GMM.tga;*_GMM.dds;*_GM.png;*_GM.tga;*_GM.dds"; >;
Texture2D excludeMaskAndAOMap < int exposed = 1; string name = "AO and Exclude Mask Map"; string desc = "The exclude mask and AO map for the material"; string groupName = "Texture Maps"; string autoValue = "{diffuseMap}_AO"; string fileFilter = "*_AO.png;*_AO.tga;*_AO.dds"; >;
Texture2D colorIdMap < int exposed = 1; string name = "Color Id Map"; string groupName = "Repaint Settings"; >;
Texture2D exclusionMap < int exposed = 1; string name = "Exclusion Map"; >;
Texture2D camoEmissionMap < int exposed = 1; string name = "Emission Map"; string groupName = "Repaint Settings.Emission Settings"; >;
Texture2D g_projectionDecalMap1 < int exposed = 1; string name = "Decal Texture"; string groupName = "Decals Settings.Decal 1"; >;
Texture2D g_projectionDecalGMMap1 < int exposed = 1; string name = "Decal Gloss"; string groupName = "Decals Settings.Decal 1"; >;
Texture2D g_projectionDecal1EmissionMap < int exposed = 1; string name = "Emission Map"; string groupName = "Decals Settings.Decal 1.Emission Settings"; >;
Texture2D g_projectionDecalMap2 < int exposed = 1; string name = "Decal Texture"; string groupName = "Decals Settings.Decal 2"; >;
Texture2D g_projectionDecalGMMap2 < int exposed = 1; string name = "Decal Gloss"; string groupName = "Decals Settings.Decal 2"; >;
Texture2D g_projectionDecal2EmissionMap < int exposed = 1; string name = "Decal Emission Map"; string groupName = "Decals Settings.Decal 2.Emission Settings"; >;
Texture2D g_projectionDecalMap3 < int exposed = 1; string name = "Decal Texture"; string groupName = "Decals Settings.Decal 3"; >;
Texture2D g_projectionDecalGMMap3 < int exposed = 1; string name = "Decal Gloss"; string groupName = "Decals Settings.Decal 3"; >;
Texture2D g_projectionDecal3EmissionMap < int exposed = 1; string name = "Decal Emission Map"; string groupName = "Decals Settings.Decal 3.Emission Settings"; >;
Texture2D g_gpuDecalsAlbedoAtlas < int exposedRuntime = 1; >;
Texture2D g_gpuDecalsNormalAtlas < int exposedRuntime = 1; >;
Texture2D g_gpuDecalsGlossMetallicAtlas < int exposedRuntime = 1; >;
Texture2D g_gpuDecalsEmissiveAtlas < int exposedRuntime = 1; >;
Texture2D g_gpuDecalsTemperatureAtlas < int exposedRuntime = 1; >;
StructuredBuffer g_gpuDecalsReceivers < int exposedRuntime = 1; >;
StructuredBuffer g_gpuDecalsAtlasBuffer < int exposedRuntime = 1; >;
StructuredBuffer g_gpuDecalsGeneralBuffer < int exposedRuntime = 1; >;
StructuredBuffer g_gpuDecalsParallaxBuffer < int exposedRuntime = 1; >;
StructuredBuffer g_gpuDecalsEmissionBuffer < int exposedRuntime = 1; >;
StructuredBuffer g_gpuDecalsAnimationBuffer < int exposedRuntime = 1; >;
StructuredBuffer g_gpuDecalsTransformBuffer < int exposedRuntime = 1; >;
StructuredBuffer g_gpuReceiversTransformBuffer < int exposedRuntime = 1; >;
StructuredBuffer g_gpuDecalsClusters < int exposedRuntime = 1; >;
StructuredBuffer g_gpuDecalsClustersCounters < int exposedRuntime = 1; >;
Texture2D g_heatMap < int exposed = 1; string name = "Part Overheat Map"; string desc = "Per part heat map that shows which areas can get heated, along with how much heating affects it"; string groupName = "Overheating Mechanic"; string autoValue = "{diffuseMap}_HM"; string fileFilter = "*_HM.png;*_HM.tga;*_HM.dds;"; >;
Texture2D g_heatColorGradient < int exposed = 1; string name = "Heat Color Gradient"; string desc = "Color gradient used for coloring parts to represent overheating"; string groupName = "Overheating Mechanic"; string autoValue = "{diffuseMap}_HCG"; string fileFilter = "*_HCG.png;*_HCG.tga;*_HCG.dds;"; >;
Texture2D metallicDetailMap < int exposed = 1; string name = "Metallic Detail Map"; string desc = "The detail map for metallic"; string groupName = "Detail Settings"; >;
