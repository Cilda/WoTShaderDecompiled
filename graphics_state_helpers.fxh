// =========================================================================
// 共通サンプラーステート定義ヘッダー (Common Sampler States)
// =========================================================================

// 1. SS_FILTER_TAA_AUTO_ADDRESS_AUTO
// TAA（テンポラルアンチエイリアス）による画面のボケを軽減するため、
// 高品質な異方性フィルタ（ANISOTROPIC）を適用し、MipLODBiasに負のバイアス（シャープ化）を与えます。
// 通常のマテリアルテクスチャでの使用を想定し、アドレスモードは WRAP とします。
SamplerState SS_FILTER_TAA_AUTO_ADDRESS_AUTO
{
    AddressU = WRAP;
    AddressV = WRAP;
    AddressW = WRAP;

    MinFilter = ANISOTROPIC;
    MagFilter = LINEAR;
    MipFilter = LINEAR;

    ComparisonFunc = NEVER;
    MipLODBias = -0.5; // TAAのボケ対策用のシャープネス補正
    MaxAnisotropy = 8;
};

// 2. SS_FILTER_LINEAR_ADDRESS_AUTO
// 標準的な三線形（トリリニア）フィルタリングを適用します。
// 標準的なマテリアルマップのデフォルト挙動を想定し、アドレスモードは WRAP とします。
SamplerState SS_FILTER_LINEAR_ADDRESS_AUTO
{
    AddressU = WRAP;
    AddressV = WRAP;
    AddressW = WRAP;

    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;

    ComparisonFunc = NEVER;
    MipLODBias = 0.0;
    MaxAnisotropy = 1;
};

// 3. SS_FILTER_AUTO_ADDRESS_WRAP
// フィルタリングはトリリニア（LINEAR）とし、アドレスモードは明示的な WRAP（繰り返し表示）とします。
SamplerState SS_FILTER_AUTO_ADDRESS_WRAP
{
    AddressU = WRAP;
    AddressV = WRAP;
    AddressW = WRAP;

    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;

    ComparisonFunc = NEVER;
    MipLODBias = 0.0;
    MaxAnisotropy = 1;
};

// 4. SS_PROJECTION_DECALS
// 投影デカール用。投影範囲外へのタイリング（繰り返し表示）を防ぐため、CLAMP とします。
// また、斜めから見た時の文字やテクスチャのボケを防ぐため、ANISOTROPIC を設定します。
SamplerState SS_PROJECTION_DECALS
{
    AddressU = CLAMP;
    AddressV = CLAMP;
    AddressW = CLAMP;

    MinFilter = ANISOTROPIC;
    MagFilter = LINEAR;
    MipFilter = LINEAR;

    ComparisonFunc = NEVER;
    MipLODBias = 0.0;
    MaxAnisotropy = 8;
};

// =========================================================================
// 共通テクニック定義
// =========================================================================

#define TECHNIQUE_COLOR_TRANSPARENT technique Color < int renderType = 0; int channelType = 0; int skinned = 0; int instanced = 0; int dualUV = 0; >