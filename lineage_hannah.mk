#               2017-2019 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_m.mk)

# Inherit some common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from hannah device
$(call inherit-product, $(LOCAL_PATH)/device.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := hannah
PRODUCT_NAME := lineage_hannah
PRODUCT_BRAND := motorola
PRODUCT_MODEL := Moto E5 Plus
PRODUCT_MANUFACTURER := motorola
PRODUCT_RELEASE_NAME := hannah

PRODUCT_ENFORCE_RRO_TARGETS := \
    framework-res

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=hannah \
    PRIVATE_BUILD_DESC="hannah_t-user 8.0.0 OCPS27.91-150-8 2 test-keys"

# Set BUILD_FINGERPRINT variable to be picked up by both system and vendor build.prop
BUILD_FINGERPRINT := motorola/hannah_t/hannah:8.0.0/OCPS27.91-150-8/2:user/test-keys
VENDOR_BUILD_FINGERPRINT := motorola/hannah_t/hannah:8.0.0/OCPS27.91-150-8/2:user/test-keys
