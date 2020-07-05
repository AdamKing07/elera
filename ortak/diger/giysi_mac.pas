{==============================================================================

  Kodlayan: Fatih KILIÇ
  Telif Bilgisi: haklar.txt dosyasına bakınız

  Dosya Adı: giysi_mac.pas
  Dosya İşlevi: pencere nesnesine mac görünümünü uygular

  Güncelleme Tarihi: 05/07/2020

  Önemli Notlar:
    1. renk değeri olarak kullanılan $FFFFFFFF değeri renk değerinin olmadığını gösterir
    2. aşağıdaki const kısmındaki isimlendirmeler son bitişine göre aşağıdaki anlamları taşır
      _S = sol, _U = üst, _G = genişlik, _Y = yükseklik

 ==============================================================================}
{$mode objfpc}
unit giysi_mac;

interface

uses paylasim;

const
  // başlık = taşıma çubuğu sabitleri
  BASLIK_Y                = 28;

  RESIM_SOLUST_G          = 8;
  RESIM_UST_G             = 4;
  RESIM_SAGUST_G          = 8;

  RESIM_SOL_G             = 2;
  RESIM_SOL_Y             = 16;
  RESIM_SAG_G             = 2;
  RESIM_SAG_Y             = 16;

  RESIM_SOLALT_G          = 10;
  RESIM_SOLALT_Y          = 10;
  RESIM_ALT_G             = 16;
  RESIM_ALT_Y             = 2;
  RESIM_SAGALT_G          = 10;
  RESIM_SAGALT_Y          = 10;

  AKTIF_BASLIK_YAZIRENGI  = RENK_SIYAH;
  PASIF_BASLIK_YAZIRENGI  = RENK_GUMUS;
  IC_DOLGU_RENGI          = $FFFFFFFF;
  BASLIK_YAZI_S           = $FFFFFFFF;
  BASLIK_YAZI_U           = $FFFFFFFF;

  // yeni değerler
  KAPATMA_DUGMESI_S       = 10;
  KAPATMA_DUGMESI_U       = 6;
  KAPATMA_DUGMESI_G       = 14;
  KAPATMA_DUGMESI_Y       = 14;
  BUYUTME_DUGMESI_S       = 50;
  BUYUTME_DUGMESI_U       = 6;
  BUYUTME_DUGMESI_G       = 14;
  BUYUTME_DUGMESI_Y       = 14;
  KUCULTME_DUGMESI_S      = 30;
  KUCULTME_DUGMESI_U      = 6;
  KUCULTME_DUGMESI_G      = 14;
  KUCULTME_DUGMESI_Y      = 14;

const
  ResimSolUstA: array[0..BASLIK_Y - 1, 0..RESIM_SOLUST_G - 1] of TRenk = (
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00939393, $00939393, $00939393),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00939393, $00939393, $00F5F5F5, $00F5F5F5, $00F5F5F5),
    ($FFFFFFFF, $FFFFFFFF, $00939393, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3),
    ($FFFFFFFF, $00939393, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3),
    ($FFFFFFFF, $00939393, $00F2F2F2, $00F2F2F2, $00F2F2F2, $00F2F2F2, $00F2F2F2, $00F2F2F2),
    ($00939393, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1),
    ($00939393, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1),
    ($00939393, $00F0F0F0, $00F0F0F0, $00F0F0F0, $00F0F0F0, $00F0F0F0, $00F0F0F0, $00F0F0F0),
    ($00939393, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF),
    ($00939393, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF),
    ($00939393, $00EEEEEE, $00EEEEEE, $00EEEEEE, $00EEEEEE, $00EEEEEE, $00EEEEEE, $00EEEEEE),
    ($00939393, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED),
    ($00939393, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED),
    ($00939393, $00ECECEC, $00ECECEC, $00ECECEC, $00ECECEC, $00ECECEC, $00ECECEC, $00ECECEC),
    ($00939393, $00EBEBEB, $00EBEBEB, $00EBEBEB, $00EBEBEB, $00EBEBEB, $00EBEBEB, $00EBEBEB),
    ($00939393, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA),
    ($00939393, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA),
    ($00939393, $00E9E9E9, $00E9E9E9, $00E9E9E9, $00E9E9E9, $00E9E9E9, $00E9E9E9, $00E9E9E9),
    ($00939393, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8),
    ($00939393, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8),
    ($00939393, $00E7E7E7, $00E7E7E7, $00E7E7E7, $00E7E7E7, $00E7E7E7, $00E7E7E7, $00E7E7E7),
    ($00939393, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6),
    ($00939393, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6),
    ($00939393, $00E5E5E5, $00E5E5E5, $00E5E5E5, $00E5E5E5, $00E5E5E5, $00E5E5E5, $00E5E5E5),
    ($00939393, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4),
    ($00939393, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4),
    ($00939393, $00E3E3E3, $00E3E3E3, $00E3E3E3, $00E3E3E3, $00E3E3E3, $00E3E3E3, $00E3E3E3),
    ($00939393, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2));

var
  ResimSolUstP: array[0..BASLIK_Y - 1, 0..RESIM_SOLUST_G - 1] of TRenk absolute ResimSolUstA;

const
  ResimUstA: array[0..BASLIK_Y - 1, 0..RESIM_UST_G - 1] of TRenk = (
    ($00939393, $00939393, $00939393, $00939393),
    ($00FBFBFB, $00FBFBFB, $00FBFBFB, $00FBFBFB),
    ($00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3),
    ($00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3),
    ($00F2F2F2, $00F2F2F2, $00F2F2F2, $00F2F2F2),
    ($00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1),
    ($00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1),
    ($00F0F0F0, $00F0F0F0, $00F0F0F0, $00F0F0F0),
    ($00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF),
    ($00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF),
    ($00EEEEEE, $00EEEEEE, $00EEEEEE, $00EEEEEE),
    ($00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED),
    ($00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED),
    ($00ECECEC, $00ECECEC, $00ECECEC, $00ECECEC),
    ($00EBEBEB, $00EBEBEB, $00EBEBEB, $00EBEBEB),
    ($00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA),
    ($00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA),
    ($00E9E9E9, $00E9E9E9, $00E9E9E9, $00E9E9E9),
    ($00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8),
    ($00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8),
    ($00E7E7E7, $00E7E7E7, $00E7E7E7, $00E7E7E7),
    ($00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6),
    ($00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6),
    ($00E5E5E5, $00E5E5E5, $00E5E5E5, $00E5E5E5),
    ($00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4),
    ($00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4),
    ($00E3E3E3, $00E3E3E3, $00E3E3E3, $00E3E3E3),
    ($00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2));

var
  ResimUstP: array[0..BASLIK_Y - 1, 0..RESIM_UST_G - 1] of TRenk absolute ResimUstA;

const
  ResimSagUstA: array[0..BASLIK_Y - 1, 0..RESIM_SAGUST_G - 1] of TRenk = (
    ($00939393, $00939393, $00939393, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($00F5F5F5, $00F5F5F5, $00F5F5F5, $00939393, $00939393, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00939393, $FFFFFFFF, $FFFFFFFF),
    ($00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00F3F3F3, $00939393, $FFFFFFFF),
    ($00F2F2F2, $00F2F2F2, $00F2F2F2, $00F2F2F2, $00F2F2F2, $00F2F2F2, $00939393, $FFFFFFFF),
    ($00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00939393),
    ($00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00F1F1F1, $00939393),
    ($00F0F0F0, $00F0F0F0, $00F0F0F0, $00F0F0F0, $00F0F0F0, $00F0F0F0, $00F0F0F0, $00939393),
    ($00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00939393),
    ($00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00EFEFEF, $00939393),
    ($00EEEEEE, $00EEEEEE, $00EEEEEE, $00EEEEEE, $00EEEEEE, $00EEEEEE, $00EEEEEE, $00939393),
    ($00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00939393),
    ($00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00EDEDED, $00939393),
    ($00ECECEC, $00ECECEC, $00ECECEC, $00ECECEC, $00ECECEC, $00ECECEC, $00ECECEC, $00939393),
    ($00EBEBEB, $00EBEBEB, $00EBEBEB, $00EBEBEB, $00EBEBEB, $00EBEBEB, $00EBEBEB, $00939393),
    ($00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00939393),
    ($00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00EAEAEA, $00939393),
    ($00E9E9E9, $00E9E9E9, $00E9E9E9, $00E9E9E9, $00E9E9E9, $00E9E9E9, $00E9E9E9, $00939393),
    ($00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00939393),
    ($00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00E8E8E8, $00939393),
    ($00E7E7E7, $00E7E7E7, $00E7E7E7, $00E7E7E7, $00E7E7E7, $00E7E7E7, $00E7E7E7, $00939393),
    ($00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00939393),
    ($00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00E6E6E6, $00939393),
    ($00E5E5E5, $00E5E5E5, $00E5E5E5, $00E5E5E5, $00E5E5E5, $00E5E5E5, $00E5E5E5, $00939393),
    ($00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00939393),
    ($00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00E4E4E4, $00939393),
    ($00E3E3E3, $00E3E3E3, $00E3E3E3, $00E3E3E3, $00E3E3E3, $00E3E3E3, $00E3E3E3, $00939393),
    ($00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00939393));

var
  ResimSagUstP: array[0..BASLIK_Y - 1, 0..RESIM_SAGUST_G - 1] of TRenk absolute ResimSagUstA;

const
  ResimSolA: array[0..RESIM_SOL_Y - 1, 0..RESIM_SOL_G - 1] of TRenk = (
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2),
    ($00939393, $00E2E2E2));

var
  ResimSolP: array[0..RESIM_SOL_Y - 1, 0..RESIM_SOL_G - 1] of TRenk absolute ResimSolA;

const
  ResimSagA: array[0..RESIM_SAG_Y - 1, 0..RESIM_SAG_G - 1] of TRenk = (
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393),
    ($00E2E2E2, $00939393));

var
  ResimSagP: array[0..RESIM_SAG_Y - 1, 0..RESIM_SAG_G - 1] of TRenk absolute ResimSagA;

const
  ResimSolAltA: array[0..RESIM_SOLALT_Y - 1, 0..RESIM_SOLALT_G - 1] of TRenk = (
    ($00939393, $00E2E2E2, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF),
    ($00939393, $00E2E2E2, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF),
    ($00939393, $00E2E2E2, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF),
    ($00939393, $00E2E2E2, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF),
    ($00939393, $00E2E2E2, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF),
    ($00939393, $00E2E2E2, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF),
    ($00939393, $00E2E2E2, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF),
    ($00939393, $00E2E2E2, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF),
    ($00939393, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2),
    ($FFFFFFFF, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393));

var
  ResimSolAltP: array[0..RESIM_SOLALT_Y - 1, 0..RESIM_SOLALT_G - 1] of TRenk absolute ResimSolAltA;

const
  ResimAltA: array[0..RESIM_ALT_Y - 1, 0..RESIM_ALT_G - 1] of TRenk = (
    ($00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2),
    ($00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393));

var
  ResimAltP: array[0..RESIM_ALT_Y - 1, 0..RESIM_ALT_G - 1] of TRenk absolute ResimAltA;

const
  ResimSagAltA: array[0..RESIM_SAGALT_Y - 1, 0..RESIM_SAGALT_G - 1] of TRenk = (
    ($00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00E2E2E2, $00939393),
    ($00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00E2E2E2, $00939393),
    ($00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00E2E2E2, $00939393),
    ($00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00E2E2E2, $00939393),
    ($00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00E2E2E2, $00939393),
    ($00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00E2E2E2, $00939393),
    ($00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00E2E2E2, $00939393),
    ($00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00FFFFFF, $00E2E2E2, $00939393),
    ($00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00E2E2E2, $00939393),
    ($00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $00939393, $FFFFFFFF));

var
  ResimSagAltP: array[0..RESIM_SAGALT_Y - 1, 0..RESIM_SAGALT_G - 1] of TRenk absolute ResimSagAltA;

const
  KapatmaDugmesiA: array[0..KAPATMA_DUGMESI_Y - 1, 0..KAPATMA_DUGMESI_G - 1] of TRenk = (
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00EDDEE0, $00E2868C, $00E14D57, $00E23E48, $00E23D48, $00E14E58, $00E2878D, $00EDDEE0, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00E6ABB0, $00E23F49, $00F04D54, $00F25056, $00F25056, $00F25056, $00F25056, $00F04D54, $00E23E49, $00E6ACB0, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $00E6ABB0, $00E8414A, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00E8414A, $00E6ACB0, $FFFFFFFF),
    ($00EBDCDE, $00E23F49, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00E23F49, $00ECDDDE),
    ($00E0848A, $00F04D54, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F04E54, $00E2868D),
    ($00E14D57, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00E14F58),
    ($00E33E49, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00E23F48),
    ($00E23F49, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00E23F49),
    ($00E04D57, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00E04E57),
    ($00DF848A, $00F04D54, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F04D54, $00E1868D),
    ($00E7D8DA, $00E23E49, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00E24049, $00E8DADB),
    ($FFFFFFFF, $00E2A8AC, $00E8414A, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00F25056, $00E8424A, $00E1A9AD, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00E2A8AC, $00E23F49, $00F04E54, $00F25056, $00F25056, $00F25056, $00F25056, $00F04D54, $00E24049, $00E1A9AD, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00E6D7D8, $00DF838A, $00E04D58, $00E23E49, $00E23E49, $00E04D58, $00DF848B, $00E6D8D9, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF));

  KapatmaDugmesiP: array[0..KAPATMA_DUGMESI_Y - 1, 0..KAPATMA_DUGMESI_G - 1] of TRenk = (
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00EDEDED, $00DFDFDF, $00D4D4D4, $00CFCFCF, $00CFCFCF, $00D4D4D4, $00DFDFDF, $00EDEDED, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00E4E4E4, $00CFCFCF, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CFCFCF, $00E4E4E4, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $00E4E4E4, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00E4E4E4, $FFFFFFFF),
    ($00EBEBEB, $00CFCFCF, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00D0D0D0, $00EBEBEB),
    ($00DDDDDD, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00DDDDDD),
    ($00D4D4D4, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00D4D4D4),
    ($00CFCFCF, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CFCFCF),
    ($00CFCFCF, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00D0D0D0),
    ($00D3D3D3, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00D3D3D3),
    ($00DCDCDC, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00DCDCDC),
    ($00E7E7E7, $00CFCFCF, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00D0D0D0, $00E7E7E7),
    ($FFFFFFFF, $00E0E0E0, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00DFDFDF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00E0E0E0, $00D0D0D0, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00CECECE, $00D0D0D0, $00DFDFDF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00E5E5E5, $00DADADA, $00D3D3D3, $00CFCFCF, $00CFCFCF, $00D3D3D3, $00DADADA, $00E5E5E5, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF));

  BuyutmeDugmesiA: array[0..BUYUTME_DUGMESI_Y - 1, 0..BUYUTME_DUGMESI_G - 1] of TRenk = (
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00DDECDE, $007BD982, $003BD446, $0028D537, $0029D536, $003BD447, $007CD982, $00DDECDE, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00A4DFA8, $002AD537, $0036E746, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0036E746, $002AD536, $00A5E0A9, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $00A4DFA8, $002CDB3A, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $002BDC3A, $00A5E0A9, $FFFFFFFF),
    ($00DBEADC, $002AD537, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $002AD437, $00DCEADC),
    ($0079D780, $0036E746, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0036E746, $007CD681),
    ($003AD345, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $003CD446),
    ($002AD437, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $002AD537),
    ($002AD537, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $002AD537),
    ($003AD345, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $003BD346),
    ($0079D67F, $0036E746, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0036E746, $007CD681),
    ($00D7E6D8, $002AD536, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $002BD437, $00D8E6D9),
    ($FFFFFFFF, $00A1DCA5, $002BDC3A, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $002BDB39, $00A2DBA6, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00A1DCA5, $002AD537, $0036E746, $0039EA49, $0039EA49, $0039EA49, $0039EA49, $0036E746, $002BD437, $00A2DBA6, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00D6E4D6, $0079D47E, $003BD246, $0029D536, $0029D536, $003BD246, $007AD57F, $00D6E4D7, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF));

var
  // büyütme düğmesinin pasif hali kapatma düğmesinin pasif hali gibidir
  BuyutmeDugmesiP: array[0..BUYUTME_DUGMESI_Y - 1, 0..BUYUTME_DUGMESI_G - 1] of TRenk absolute KapatmaDugmesiP;

const
  KucultmeDugmesiA: array[0..KUCULTME_DUGMESI_Y - 1, 0..KUCULTME_DUGMESI_G - 1] of TRenk = (
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00EEE9DC, $00E6C679, $00E6B439, $00E9B126, $00E9B126, $00E6B53A, $00E6C67A, $00EEE9DC, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00E8D4A3, $00E9B227, $00F8C334, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00F8C334, $00E9B127, $00E8D4A4, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $00E8D4A3, $00EFB729, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00EFB729, $00E8D4A4, $FFFFFFFF),
    ($00ECE7DA, $00E9B227, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00E9B228, $00ECE7DB),
    ($00E4C477, $00F8C334, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00F8C333, $00E4C57A),
    ($00E6B438, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00E7B53A),
    ($00E9B227, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00E9B227),
    ($00E9B227, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00E9B128),
    ($00E5B338, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00E6B439),
    ($00E3C377, $00F8C334, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00F7C233, $00E3C47A),
    ($00E8E3D6, $00E9B127, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00E9B227, $00E8E3D8),
    ($FFFFFFFF, $00E4D0A0, $00EFB729, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00EEB628, $00E3D0A1, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $00E4D0A0, $00E9B128, $00F8C333, $00FAC536, $00FAC536, $00FAC536, $00FAC536, $00F7C233, $00E9B227, $00E3D0A1, $FFFFFFFF, $FFFFFFFF),
    ($FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $00E6E1D5, $00E1C277, $00E5B439, $00E9B126, $00E9B126, $00E5B439, $00E1C278, $00E6E1D6, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF));

var
  // küçültme düğmesinin pasif hali kapatma düğmesinin pasif hali gibidir
  KucultmeDugmesiP: array[0..KUCULTME_DUGMESI_Y - 1, 0..KUCULTME_DUGMESI_G - 1] of TRenk absolute KapatmaDugmesiP;

var
  GiysiMac: TGiysi = (
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
    ResimSagAltP: (Genislik: RESIM_SAGALT_G;  Yukseklik: RESIM_SAGALT_Y;  BellekAdresi: @ResimSagAltP));

implementation

end.
