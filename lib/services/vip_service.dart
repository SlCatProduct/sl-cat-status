import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VipTier {
  free,
  monthly,
  yearly,
  lifetime,
  promo,
}

class VipService extends ChangeNotifier {
  static final VipService _instance = VipService._internal();
  factory VipService() => _instance;
  VipService._internal();

  static const String _keyIsVip = 'sl_cat_is_vip';
  static const String _keyVipTier = 'sl_cat_vip_tier';
  static const String _keyCustomWatermark = 'sl_cat_custom_watermark';

  static const Set<String> _productIds = {
    'slcat_vip_monthly',
    'slcat_vip_yearly',
    'slcat_vip_lifetime',
  };

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isVip = false;
  VipTier _tier = VipTier.free;
  String _customWatermarkText = '';
  bool _isStoreAvailable = false;
  List<ProductDetails> _products = [];
  bool _isLoading = false;

  bool get isVip => _isVip;
  VipTier get tier => _tier;
  String get customWatermarkText => _customWatermarkText;
  bool get isStoreAvailable => _isStoreAvailable;
  List<ProductDetails> get products => _products;
  bool get isLoading => _isLoading;

  String get tierDisplayName {
    switch (_tier) {
      case VipTier.lifetime:
        return 'LIFETIME VIP';
      case VipTier.yearly:
        return 'ANNUAL VIP';
      case VipTier.monthly:
        return 'MONTHLY VIP';
      case VipTier.promo:
        return 'PRO VIP (UNLOCKED)';
      case VipTier.free:
      default:
        return 'FREE TIER';
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isVip = prefs.getBool(_keyIsVip) ?? false;
      final savedTier = prefs.getString(_keyVipTier) ?? 'free';
      _tier = _tierFromString(savedTier);
      _customWatermarkText = prefs.getString(_keyCustomWatermark) ?? '';

      // Initialize IAP listener
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (err) {
          debugPrint('IAP purchaseStream error: $err');
        },
      );

      _isStoreAvailable = await _inAppPurchase.isAvailable();
      if (_isStoreAvailable) {
        final response = await _inAppPurchase.queryProductDetails(_productIds);
        if (response.notFoundIDs.isNotEmpty) {
          debugPrint('IAP Products not found: ${response.notFoundIDs}');
        }
        _products = response.productDetails;
      }
    } catch (e) {
      debugPrint('Error initializing VipService: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == 'slcat_vip_lifetime') {
          await _setVipStatus(true, VipTier.lifetime);
        } else if (purchase.productID == 'slcat_vip_yearly') {
          await _setVipStatus(true, VipTier.yearly);
        } else if (purchase.productID == 'slcat_vip_monthly') {
          await _setVipStatus(true, VipTier.monthly);
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  Future<void> _setVipStatus(bool active, VipTier tier) async {
    _isVip = active;
    _tier = tier;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsVip, active);
    await prefs.setString(_keyVipTier, tier.name);
    notifyListeners();
  }

  Future<bool> buyProduct(ProductDetails product) async {
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      if (product.id == 'slcat_vip_lifetime') {
        return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        return await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('Error buying product: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  /// Secret / Promo code unlock for testers & user
  bool redeemPromoCode(String inputCode) {
    final code = inputCode.trim().toUpperCase();
    const validCodes = {'SLCATVIP', 'SLCAT2026', 'VIPPRO', 'PURESTATUS', 'SLPRO'};

    if (validCodes.contains(code)) {
      _setVipStatus(true, VipTier.promo);
      return true;
    }
    return false;
  }

  Future<void> setCustomWatermarkText(String text) async {
    _customWatermarkText = text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomWatermark, _customWatermarkText);
    notifyListeners();
  }

  Future<void> resetVipForTesting() async {
    await _setVipStatus(false, VipTier.free);
  }

  VipTier _tierFromString(String str) {
    switch (str) {
      case 'lifetime':
        return VipTier.lifetime;
      case 'yearly':
        return VipTier.yearly;
      case 'monthly':
        return VipTier.monthly;
      case 'promo':
        return VipTier.promo;
      default:
        return VipTier.free;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
