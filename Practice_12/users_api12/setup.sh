#!/bin/bash
set -e
cd "$(dirname "$0")"
flutter pub add shared_preferences flutter_secure_storage path_provider image_picker permission_handler url_launcher
flutter pub get
flutter pub outdated
dart format lib test
flutter analyze
flutter test
