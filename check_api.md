# API Centralization Summary

## Overview
All API URLs and related constants have been centralized into `lib/core/constants/api_constants.dart`.
Hardcoded URLs found in repositories, models, and views have been replaced with references to this central file.

## Files Updated
1.  **Core:**
    - `lib/core/constants/api_constants.dart`: Created/Updated to hold all API constants.
    - `lib/core/network/api_client.dart`: Updated to use constants for timeouts and headers.

2.  **Repositories:**
    - `lib/data/repositories/auth_repository.dart`
    - `lib/data/repositories/category_repository.dart`
    - `lib/data/repositories/product_repository.dart`
    - `lib/data/repositories/brand_repository.dart`

3.  **Models:**
    - `lib/data/models/product_model.dart`: Updated image URL generation.
    - `lib/data/models/brand_model.dart`: Updated logo URL generation.

4.  **Presentation (Views & View Models):**
    - `lib/presentation/view_model/product_details_service.dart`
    - `lib/presentation/view_model/search_provider.dart`
    - `lib/presentation/views/widgets/category_widget/category_card.dart`
    - `lib/presentation/views/views/flash_sale_banner.dart`

## Verification
A final grep search for the old domain `furniture-store.ztajir.com` confirms that it effectively only exists in `ApiConstants.dart` (or as comments/imports that were removed/updated).
Brands implementation was specifically doubly checked and confirmed to be using the new constants.
