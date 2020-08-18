{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: giysi_normal.pas
  Dosya İşlevi: pencere nesnesine normal görünüm uygular

  Güncelleme Tarihi: 09/08/2020

  Önemli Notlar:
    1. renk değeri olarak kullanılan -1 değeri renk değerinin olmadığını gösterir
    2. aşağıdaki const kısmındaki isimlendirmeler son bitişine göre aşağıdaki anlamları taşır
      _S = sol, _U = üst, _G = genişlik, _Y = yükseklik

 ==============================================================================}
{$mode objfpc}
unit giysi_normal;

interface

uses paylasim;

const
  // başlık = taşıma çubuğu sabitleri
  BASLIK_Y                = 24;

  RESIM_SOLUST_G          = 8;
  RESIM_UST_G             = 4;
  RESIM_SAGUST_G          = 8;

  RESIM_SOL_G             = 5;
  RESIM_SOL_Y             = 16;
  RESIM_SAG_G             = 5;
  RESIM_SAG_Y             = 16;

  RESIM_SOLALT_G          = 5;
  RESIM_SOLALT_Y          = 5;
  RESIM_ALT_G             = 16;
  RESIM_ALT_Y             = 5;
  RESIM_SAGALT_G          = 5;
  RESIM_SAGALT_Y          = 5;

  AKTIF_BASLIK_YAZIRENGI  = RENK_BEYAZ;
  PASIF_BASLIK_YAZIRENGI  = RENK_GUMUS;
  IC_DOLGU_RENGI          = -1;
  BASLIK_YAZI_S           = -1;
  BASLIK_YAZI_U           = -1;

  // yeni değerler
  KAPATMA_DUGMESI_S       = -25;
  KAPATMA_DUGMESI_U       = 5;
  KAPATMA_DUGMESI_G       = 12;
  KAPATMA_DUGMESI_Y       = 12;
  BUYUTME_DUGMESI_S       = -45;
  BUYUTME_DUGMESI_U       = 5;
  BUYUTME_DUGMESI_G       = 12;
  BUYUTME_DUGMESI_Y       = 12;
  KUCULTME_DUGMESI_S      = -65;
  KUCULTME_DUGMESI_U      = 5;
  KUCULTME_DUGMESI_G      = 12;
  KUCULTME_DUGMESI_Y      = 12;

const
  ResimSolUstA: array[0..BASLIK_Y - 1, 0..RESIM_SOLUST_G - 1] of TRenk = (
    ($00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010),
    ($00000000, $00B8C8DC, $00B7C7DA, $00B7C7DA, $00B7C7DA, $00B7C7DA, $00B7C7DA, $00B7C7DA),
    ($00000000, $00BCCEE3, $00BCCEE3, $00BCCEE3, $00889EBB, $00889EBB, $00889EBB, $00889EBB),
    ($00000000, $00B9C9DD, $00B9C9DD, $00B9C9DD, $00889EBB, $00889EBB, $00889EBB, $00889EBB),
    ($00000000, $00B9C9DD, $00B9C9DD, $00B9C9DD, $008194AD, $008194AD, $008194AD, $008194AD),
    ($00000000, $00B4C2D4, $00B4C2D4, $00B4C2D4, $0079899F, $0079899F, $0079899F, $0079899F),
    ($00000000, $00AFBACA, $00AFBACA, $00AFBACA, $00718091, $00718091, $00718091, $00718091),
    ($00000000, $00A8B3C0, $00A8B3C0, $00A8B3C0, $00616B78, $00616B78, $00616B78, $00616B78),
    ($00000000, $00A2ABB7, $00A2ABB7, $00A2ABB7, $00616B78, $00616B78, $00616B78, $00616B78),
    ($00000000, $009EA6AE, $009EA6AE, $009EA6AE, $005B6571, $005B6571, $005B6571, $005B6571),
    ($00000000, $009EA6AE, $009EA6AE, $009EA6AE, $005B6571, $005B6571, $005B6571, $005B6571),
    ($00000000, $009EA6AE, $009EA6AE, $009EA6AE, $005B6571, $005B6571, $005B6571, $005B6571),
    ($00000000, $0069737F, $0069737F, $0069737F, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($00000000, $0069737F, $0069737F, $0069737F, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($00000000, $0069737F, $0069737F, $0069737F, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($00000000, $00677380, $00677380, $00677380, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($00000000, $00657785, $00657785, $00657785, $00092137, $00092137, $00092137, $00092137),
    ($00000000, $00647C90, $00647C90, $00647C90, $00062945, $00062945, $00062945, $00062945),
    ($00000000, $00647C90, $00647C90, $00647C90, $00063458, $00063458, $00063458, $00063458),
    ($00000000, $0063839D, $0063839D, $0063839D, $0004416F, $0004416F, $0004416F, $0004416F),
    ($00000000, $00628EAD, $00628EAD, $00628EAD, $00035086, $00035086, $00035086, $00035086),
    ($00000000, $006297BF, $006297BF, $006297BF, $00035F9F, $00035F9F, $00035F9F, $00035F9F),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010, $00101010, $00101010, $00101010));

  ResimSolUstP: array[0..BASLIK_Y - 1, 0..RESIM_SOLUST_G - 1] of TRenk = (
    ($00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010),
    ($00101010, $00ACACAC, $00ACACAC, $00ACACAC, $00ACACAC, $00ACACAC, $00ACACAC, $00ACACAC),
    ($00101010, $00A2A2A2, $00A2A2A2, $00A2A2A2, $00858585, $00858585, $00858585, $00858585),
    ($00101010, $009A9A9A, $009A9A9A, $009A9A9A, $007B7B7B, $007B7B7B, $007B7B7B, $007B7B7B),
    ($00101010, $009A9A9A, $009A9A9A, $009A9A9A, $007B7B7B, $007B7B7B, $007B7B7B, $007B7B7B),
    ($00101010, $00969696, $00969696, $00969696, $00747474, $00747474, $00747474, $00747474),
    ($00101010, $00969696, $00969696, $00969696, $00676767, $00676767, $00676767, $00676767),
    ($00101010, $00929292, $00929292, $00929292, $00676767, $00676767, $00676767, $00676767),
    ($00101010, $00909090, $00909090, $00909090, $00616161, $00616161, $00616161, $00616161),
    ($00101010, $00909090, $00909090, $00909090, $005E5E5E, $005E5E5E, $005E5E5E, $005E5E5E),
    ($00101010, $00909090, $00909090, $00909090, $005E5E5E, $005E5E5E, $005E5E5E, $005E5E5E),
    ($00101010, $00909090, $00909090, $00909090, $005E5E5E, $005E5E5E, $005E5E5E, $005E5E5E),
    ($00101010, $00626262, $00626262, $00626262, $00242424, $00242424, $00242424, $00242424),
    ($00101010, $00626262, $00626262, $00626262, $00242424, $00242424, $00242424, $00242424),
    ($00101010, $00626262, $00626262, $00626262, $00242424, $00242424, $00242424, $00242424),
    ($00101010, $00646464, $00646464, $00646464, $00222222, $00222222, $00222222, $00222222),
    ($00101010, $00646464, $00646464, $00646464, $00272727, $00272727, $00272727, $00272727),
    ($00101010, $00666666, $00666666, $00666666, $002B2B2B, $002B2B2B, $002B2B2B, $002B2B2B),
    ($00101010, $00666666, $00666666, $00666666, $002B2B2B, $002B2B2B, $002B2B2B, $002B2B2B),
    ($00101010, $00686868, $00686868, $00686868, $00303030, $00303030, $00303030, $00303030),
    ($00101010, $006C6C6C, $006C6C6C, $006C6C6C, $00343434, $00343434, $00343434, $00343434),
    ($00101010, $00727272, $00727272, $00727272, $003D3D3D, $003D3D3D, $003D3D3D, $003D3D3D),
    ($00101010, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272),
    ($00181818, $00727272, $00727272, $00727272, $00000000, $00000000, $00000000, $00000000));

  ResimUstA: array[0..BASLIK_Y - 1, 0..RESIM_UST_G - 1] of TRenk = (
    ($00101010, $00101010, $00101010, $00101010),
    ($00B7C7DA, $00B7C7DA, $00B7C7DA, $00B7C7DA),
    ($00889EBB, $00889EBB, $00889EBB, $00889EBB),
    ($00889EBB, $00889EBB, $00889EBB, $00889EBB),
    ($008194AD, $008194AD, $008194AD, $008194AD),
    ($0079899F, $0079899F, $0079899F, $0079899F),
    ($00718091, $00718091, $00718091, $00718091),
    ($00616B78, $00616B78, $00616B78, $00616B78),
    ($00616B78, $00616B78, $00616B78, $00616B78),
    ($005B6571, $005B6571, $005B6571, $005B6571),
    ($005B6571, $005B6571, $005B6571, $005B6571),
    ($005B6571, $005B6571, $005B6571, $005B6571),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($00092137, $00092137, $00092137, $00092137),
    ($00062945, $00062945, $00062945, $00062945),
    ($00063458, $00063458, $00063458, $00063458),
    ($0004416F, $0004416F, $0004416F, $0004416F),
    ($00035086, $00035086, $00035086, $00035086),
    ($00035F9F, $00035F9F, $00035F9F, $00035F9F),
    ($00609FCC, $00609FCC, $00609FCC, $00609FCC),
    ($00101010, $00101010, $00101010, $00101010));

  ResimUstP: array[0..BASLIK_Y - 1, 0..RESIM_UST_G - 1] of TRenk = (
    ($00101010, $00101010, $00101010, $00101010),
    ($00ACACAC, $00ACACAC, $00ACACAC, $00ACACAC),
    ($00858585, $00858585, $00858585, $00858585),
    ($007B7B7B, $007B7B7B, $007B7B7B, $007B7B7B),
    ($007B7B7B, $007B7B7B, $007B7B7B, $007B7B7B),
    ($00747474, $00747474, $00747474, $00747474),
    ($00676767, $00676767, $00676767, $00676767),
    ($00676767, $00676767, $00676767, $00676767),
    ($00616161, $00616161, $00616161, $00616161),
    ($005E5E5E, $005E5E5E, $005E5E5E, $005E5E5E),
    ($005E5E5E, $005E5E5E, $005E5E5E, $005E5E5E),
    ($005E5E5E, $005E5E5E, $005E5E5E, $005E5E5E),
    ($00242424, $00242424, $00242424, $00242424),
    ($00242424, $00242424, $00242424, $00242424),
    ($00242424, $00242424, $00242424, $00242424),
    ($00222222, $00222222, $00222222, $00222222),
    ($00272727, $00272727, $00272727, $00272727),
    ($002B2B2B, $002B2B2B, $002B2B2B, $002B2B2B),
    ($002B2B2B, $002B2B2B, $002B2B2B, $002B2B2B),
    ($00303030, $00303030, $00303030, $00303030),
    ($00343434, $00343434, $00343434, $00343434),
    ($003D3D3D, $003D3D3D, $003D3D3D, $003D3D3D),
    ($00727272, $00727272, $00727272, $00727272),
    ($00000000, $00000000, $00000000, $00000000));

  ResimSagUstA: array[0..BASLIK_Y - 1, 0..RESIM_SAGUST_G - 1] of TRenk = (
    ($00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010),
    ($00B7C7DA, $00B7C7DA, $00B7C7DA, $00B7C7DA, $00B7C7DA, $00B7C7DA, $00B8C8DC, $00000000),
    ($00889EBB, $00889EBB, $00889EBB, $00889EBB, $00BCCEE3, $00BCCEE3, $00BCCEE3, $00000000),
    ($00889EBB, $00889EBB, $00889EBB, $00889EBB, $00B9C9DD, $00B9C9DD, $00B9C9DD, $00000000),
    ($008194AD, $008194AD, $008194AD, $008194AD, $00B9C9DD, $00B9C9DD, $00B9C9DD, $00000000),
    ($0079899F, $0079899F, $0079899F, $0079899F, $00B4C2D4, $00B4C2D4, $00B4C2D4, $00000000),
    ($00718091, $00718091, $00718091, $00718091, $00AFBACA, $00AFBACA, $00AFBACA, $00000000),
    ($00616B78, $00616B78, $00616B78, $00616B78, $00A8B3C0, $00A8B3C0, $00A8B3C0, $00000000),
    ($00616B78, $00616B78, $00616B78, $00616B78, $00A2ABB7, $00A2ABB7, $00A2ABB7, $00000000),
    ($005B6571, $005B6571, $005B6571, $005B6571, $009EA6AE, $009EA6AE, $009EA6AE, $00000000),
    ($005B6571, $005B6571, $005B6571, $005B6571, $009EA6AE, $009EA6AE, $009EA6AE, $00000000),
    ($005B6571, $005B6571, $005B6571, $005B6571, $009EA6AE, $009EA6AE, $009EA6AE, $00000000),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $0069737F, $0069737F, $0069737F, $00000000),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $0069737F, $0069737F, $0069737F, $00000000),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $0069737F, $0069737F, $0069737F, $00000000),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $00677380, $00677380, $00677380, $00000000),
    ($00092137, $00092137, $00092137, $00092137, $00657785, $00657785, $00657785, $00000000),
    ($00062945, $00062945, $00062945, $00062945, $00647C90, $00647C90, $00647C90, $00000000),
    ($00063458, $00063458, $00063458, $00063458, $00647C90, $00647C90, $00647C90, $00000000),
    ($0004416F, $0004416F, $0004416F, $0004416F, $0063839D, $0063839D, $0063839D, $00000000),
    ($00035086, $00035086, $00035086, $00035086, $00628EAD, $00628EAD, $00628EAD, $00000000),
    ($00035F9F, $00035F9F, $00035F9F, $00035F9F, $006297BF, $006297BF, $006297BF, $00000000),
    ($00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00000000),
    ($00101010, $00101010, $00101010, $00101010, $00609FCC, $00609FCC, $00609FCC, $00000000));

  ResimSagUstP: array[0..BASLIK_Y - 1, 0..RESIM_SAGUST_G - 1] of TRenk = (
    ($00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010),
    ($00ACACAC, $00ACACAC, $00ACACAC, $00ACACAC, $00ACACAC, $00ACACAC, $00ACACAC, $00101010),
    ($00858585, $00858585, $00858585, $00858585, $00A2A2A2, $00A2A2A2, $00A2A2A2, $00101010),
    ($007B7B7B, $007B7B7B, $007B7B7B, $007B7B7B, $009A9A9A, $009A9A9A, $009A9A9A, $00101010),
    ($007B7B7B, $007B7B7B, $007B7B7B, $007B7B7B, $009A9A9A, $009A9A9A, $009A9A9A, $00101010),
    ($00747474, $00747474, $00747474, $00747474, $00969696, $00969696, $00969696, $00101010),
    ($00676767, $00676767, $00676767, $00676767, $00969696, $00969696, $00969696, $00101010),
    ($00676767, $00676767, $00676767, $00676767, $00929292, $00929292, $00929292, $00101010),
    ($00616161, $00616161, $00616161, $00616161, $00909090, $00909090, $00909090, $00101010),
    ($005E5E5E, $005E5E5E, $005E5E5E, $005E5E5E, $00909090, $00909090, $00909090, $00101010),
    ($005E5E5E, $005E5E5E, $005E5E5E, $005E5E5E, $00909090, $00909090, $00909090, $00101010),
    ($005E5E5E, $005E5E5E, $005E5E5E, $005E5E5E, $00909090, $00909090, $00909090, $00101010),
    ($00242424, $00242424, $00242424, $00242424, $00626262, $00626262, $00626262, $00101010),
    ($00242424, $00242424, $00242424, $00242424, $00626262, $00626262, $00626262, $00101010),
    ($00242424, $00242424, $00242424, $00242424, $00626262, $00626262, $00626262, $00101010),
    ($00222222, $00222222, $00222222, $00222222, $00646464, $00646464, $00646464, $00101010),
    ($00272727, $00272727, $00272727, $00272727, $00646464, $00646464, $00646464, $00101010),
    ($002B2B2B, $002B2B2B, $002B2B2B, $002B2B2B, $00666666, $00666666, $00666666, $00101010),
    ($002B2B2B, $002B2B2B, $002B2B2B, $002B2B2B, $00666666, $00666666, $00666666, $00101010),
    ($00303030, $00303030, $00303030, $00303030, $00686868, $00686868, $00686868, $00101010),
    ($00343434, $00343434, $00343434, $00343434, $006C6C6C, $006C6C6C, $006C6C6C, $00101010),
    ($003D3D3D, $003D3D3D, $003D3D3D, $003D3D3D, $00727272, $00727272, $00727272, $00101010),
    ($00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00101010),
    ($00000000, $00000000, $00000000, $00000000, $00727272, $00727272, $00727272, $00181818));

  ResimSolA: array[0..RESIM_SOL_Y - 1, 0..RESIM_SOL_G - 1] of TRenk = (
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010));

  ResimSolP: array[0..RESIM_SOL_Y - 1, 0..RESIM_SOL_G - 1] of TRenk = (
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010));

  ResimSagA: array[0..RESIM_SAG_Y - 1, 0..RESIM_SAG_G - 1] of TRenk = (
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00000000, $00609FCC, $00609FCC, $00609FCC, $00101010));

  ResimSagP: array[0..RESIM_SAG_Y - 1, 0..RESIM_SAG_G - 1] of TRenk = (
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00101010));

  ResimSolAltA: array[0..RESIM_SOLALT_Y - 1, 0..RESIM_SOLALT_G - 1] of TRenk = (
    ($00101010, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00101010, $00609FCC, $00609FCC, $00609FCC, $00609FCC),
    ($00101010, $00609FCC, $00609FCC, $00609FCC, $00609FCC),
    ($00101010, $00609FCC, $00609FCC, $00609FCC, $00609FCC),
    ($00000000, $00000000, $00000000, $00000000, $00101010));

  ResimSolAltP: array[0..RESIM_SOLALT_Y - 1, 0..RESIM_SOLALT_G - 1] of TRenk = (
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00727272, $00727272, $00727272, $00727272),
    ($00101010, $00727272, $00727272, $00727272, $00727272),
    ($00101010, $00727272, $00727272, $00727272, $00727272),
    ($00000000, $00000000, $00000000, $00000000, $00101010));

  ResimAltA: array[0..RESIM_ALT_Y - 1, 0..RESIM_ALT_G - 1] of TRenk = (
    ($00000000, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010),
    ($00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC),
    ($00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC),
    ($00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC, $00609FCC),
    ($00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010));

  ResimAltP: array[0..RESIM_ALT_Y - 1, 0..RESIM_ALT_G - 1] of TRenk = (
    ($00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010),
    ($00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272),
    ($00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272),
    ($00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272, $00727272),
    ($00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010, $00101010));

  ResimSagAltA: array[0..RESIM_SAGALT_Y - 1, 0..RESIM_SAGALT_G - 1] of TRenk = (
    ($00101010, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00609FCC, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00609FCC, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00609FCC, $00609FCC, $00609FCC, $00609FCC, $00101010),
    ($00101010, $00000000, $00000000, $00000000, $00000000));

  ResimSagAltP: array[0..RESIM_SAGALT_Y - 1, 0..RESIM_SAGALT_G - 1] of TRenk = (
    ($00101010, $00727272, $00727272, $00727272, $00101010),
    ($00727272, $00727272, $00727272, $00727272, $00101010),
    ($00727272, $00727272, $00727272, $00727272, $00101010),
    ($00727272, $00727272, $00727272, $00727272, $00101010),
    ($00101010, $00000000, $00000000, $00000000, $00000000));

const
  KapatmaDugmesiA: array[0..KAPATMA_DUGMESI_Y - 1, 0..KAPATMA_DUGMESI_G - 1] of TRenk = (
    ($00000000, $00000000, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00000000, $00000000),
    ($00000000, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF, $FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000),
    ($FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF),
    ($00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF, $FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00FFFFFF, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00000000),
    ($00000000, $00000000, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00000000, $00000000));

  KapatmaDugmesiP: array[0..KAPATMA_DUGMESI_Y - 1, 0..KAPATMA_DUGMESI_G - 1] of TRenk = (
    ($00000000, $00000000, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00000000, $00000000),
    ($00000000, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF, $FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000),
    ($FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF),
    ($00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF, $FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00C0C0C0, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00C0C0C0, $00C0C0C0, $00000000),
    ($00000000, $00000000, $00000000, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00000000, $00000000, $00000000));

  BuyutmeDugmesiA: array[0..BUYUTME_DUGMESI_Y - 1, 0..BUYUTME_DUGMESI_G - 1] of TRenk = (
    ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000),
    ($00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000),
    ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000));

  BuyutmeDugmesiP: array[0..BUYUTME_DUGMESI_Y - 1, 0..BUYUTME_DUGMESI_G - 1] of TRenk = (
    ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000),
    ($00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000),
    ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000));

  KucultmeDugmesiA: array[0..KUCULTME_DUGMESI_Y - 1, 0..KUCULTME_DUGMESI_G - 1] of TRenk = (
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000),
    ($00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000),
    ($00000000, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00000000),
    ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000));

  KucultmeDugmesiP: array[0..KUCULTME_DUGMESI_Y - 1, 0..KUCULTME_DUGMESI_G - 1] of TRenk = (
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C, $000F1C2C),
    ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000),
    ($00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000),
    ($00000000, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00C0C0C0, $00000000),
    ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000));

var
  GiysiNormal: TGiysi = (
    BaslikYukseklik         : BASLIK_Y;

    ResimSolUstGenislik     : RESIM_SOLUST_G;
    ResimUstGenislik        : RESIM_UST_G;
    ResimSagUstGenislik     : RESIM_SAGUST_G;

    ResimSolGenislik        : RESIM_SOL_G;
    ResimSolYukseklik       : RESIM_SOL_Y;
    ResimSagGenislik        : RESIM_SAG_G;
    ResimSagYukseklik       : RESIM_SAG_Y;

    ResimSolAltGenislik     : RESIM_SOLALT_G;
    ResimSolAltYukseklik    : RESIM_SOLALT_Y;
    ResimAltGenislik        : RESIM_ALT_G;
    ResimAltYukseklik       : RESIM_ALT_Y;
    ResimSagAltGenislik     : RESIM_SAGALT_G;
    ResimSagAltYukseklik    : RESIM_SAGALT_Y;

    AktifBaslikYaziRengi    : AKTIF_BASLIK_YAZIRENGI;
    PasifBaslikYaziRengi    : PASIF_BASLIK_YAZIRENGI;
    IcDolguRengi            : IC_DOLGU_RENGI;     // pencere iç rengi sistem tarafından belirlenecek
    BaslikYaziSol           : BASLIK_YAZI_S;      // başlığın sol başlangıç değeri pencerenin ortası olarak belirlenecek
    BaslikYaziUst           : BASLIK_YAZI_U;      // başlığın üst başlangıç değeri pencerenin ortası olarak belirlenecek

    KapatmaDugmesiSol       : KAPATMA_DUGMESI_S;
    KapatmaDugmesiUst       : KAPATMA_DUGMESI_U;
    KapatmaDugmesiGenislik  : KAPATMA_DUGMESI_G;
    KapatmaDugmesiYukseklik : KAPATMA_DUGMESI_Y;
    BuyutmeDugmesiSol       : BUYUTME_DUGMESI_S;
    BuyutmeDugmesiUst       : BUYUTME_DUGMESI_U;
    BuyutmeDugmesiGenislik  : BUYUTME_DUGMESI_G;
    BuyutmeDugmesiYukseklik : BUYUTME_DUGMESI_Y;
    KucultmeDugmesiSol      : KUCULTME_DUGMESI_S;
    KucultmeDugmesiUst      : KUCULTME_DUGMESI_U;
    KucultmeDugmesiGenislik : KUCULTME_DUGMESI_G;
    KucultmeDugmesiYukseklik: KUCULTME_DUGMESI_Y;

    ResimSolUstA: (Genislik: RESIM_SOLUST_G;  Yukseklik: BASLIK_Y;        BellekAdresi: @ResimSolUstA);
    ResimSolUstP: (Genislik: RESIM_SOLUST_G;  Yukseklik: BASLIK_Y;        BellekAdresi: @ResimSolUstP);
    ResimUstA:    (Genislik: RESIM_UST_G;     Yukseklik: BASLIK_Y;        BellekAdresi: @ResimUstA);
    ResimUstP:    (Genislik: RESIM_UST_G;     Yukseklik: BASLIK_Y;        BellekAdresi: @ResimUstP);
    ResimSagUstA: (Genislik: RESIM_SAGUST_G;  Yukseklik: BASLIK_Y;        BellekAdresi: @ResimSagUstA);
    ResimSagUstP: (Genislik: RESIM_SAGUST_G;  Yukseklik: BASLIK_Y;        BellekAdresi: @ResimSagUstP);
    ResimSolA:    (Genislik: RESIM_SOL_G;     Yukseklik: RESIM_SOL_Y;     BellekAdresi: @ResimSolA);
    ResimSolP:    (Genislik: RESIM_SOL_G;     Yukseklik: RESIM_SOL_Y;     BellekAdresi: @ResimSolP);
    ResimSagA:    (Genislik: RESIM_SAG_G;     Yukseklik: RESIM_SAG_Y;     BellekAdresi: @ResimSagA);
    ResimSagP:    (Genislik: RESIM_SAG_G;     Yukseklik: RESIM_SAG_Y;     BellekAdresi: @ResimSagP);
    ResimSolAltA: (Genislik: RESIM_SOLALT_G;  Yukseklik: RESIM_SOLALT_Y;  BellekAdresi: @ResimSolAltA);
    ResimSolAltP: (Genislik: RESIM_SOLALT_G;  Yukseklik: RESIM_SOLALT_Y;  BellekAdresi: @ResimSolAltP);
    ResimAltA:    (Genislik: RESIM_ALT_G;     Yukseklik: RESIM_ALT_Y;     BellekAdresi: @ResimAltA);
    ResimAltP:    (Genislik: RESIM_ALT_G;     Yukseklik: RESIM_ALT_Y;     BellekAdresi: @ResimAltP);
    ResimSagAltA: (Genislik: RESIM_SAGALT_G;  Yukseklik: RESIM_SAGALT_Y;  BellekAdresi: @ResimSagAltA);
    ResimSagAltP: (Genislik: RESIM_SAGALT_G;  Yukseklik: RESIM_SAGALT_Y;  BellekAdresi: @ResimSagAltP);

    AKapatmaDugmesiRSNo   : 6;
    ABuyutmeDugmesiRSNo   : 8;
    AKucultmeDugmesiRSNo  : 10;
    PKapatmaDugmesiRSNo   : 7;
    PBuyutmeDugmesiRSNo   : 9;
    PKucultmeDugmesiRSNo  : 11;
);

implementation

end.
