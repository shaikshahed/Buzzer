# ALlTheNews Android TV

A## Flutter commands ##

### Flutter pub get

flutter pub get

### Flutter clean

flutter clean

### Flutter build Runner

dart run build_runner build --delete-conflicting-outputs

### Generate app icons
run this command after changing the app icon. <br />

dart run flutter_launcher_icons

### Generate app localizations

"flutter gen-l10n"

### Build APK - RELEASE

"flutter build apk --release lib/main/main_development.dart"

## IMPORTANT

respect lint issues

## Main

All repositories must be included in main, <br />
authentication Bloc, user data Bloc included in main.

bloc which are limited to feature will be within the feature

## Using Extensions

in ClassA class(class_a.dart), create <br />
-> part 'class_b.dart'; <br />
in ClassB class(class_b.dart), create <br />
-> part of 'class_a.dart'; <br />
ClassB is extension of ClassA. <br />

## Cubit

Cubit is used in Permissions screen instead of bloc.

## Navigation using go_router

GoRouter.go("route_name") or context.go("route_name") -> removes all the previous stacks. <br />
GoRouter.push("route_name") or context.push("route_name") -> keeps the earlier stacks. <br />
GoRouter.of(context).pop() -> moves to previous stack. <br />
GoRouter.of(context).pushReplacement("route_name") -> replaces the top stack <br />

// default navigation
Navigator.of(context).pop() -> used in dismissing dialogs <br />

for more info, visit: https://pub.dev/packages/go_router

## Flutter lint rules

visit: https://dart.dev/tools/linter-rules/prefer_relative_imports

## Files & folder structure

new feature ->

### UI

../feature/ui
../feature/ui/components -> widgets used only for feature

### Bloc

../feature/bloc -> bloc used only for feature

### Models

../feature/models -> models used only for feature

### Repository

../feature/repo -> repo used only for feature

### Common widgets

../widgets

### Shared resources

## Models

../weyyak_flutter_dev/shared/models <br />
../weyyak_flutter_dev/shared/repository <br />

all the database related into /database_repository <br />
all the content related into /content_repository <br />

## Widgets

### Format:

This is to be followed. <br />

wk_name_widget.dart <br />
class name: WkNameWidget <br />
widget_name = your widget name. <br />

### Example:

wk_loader_widget.dart <br />
class name: WkLoaderWidget <br />


#### links
https://www.youtube.com/watch?v=bWehAFTFc9o&t=125s -> share

#### to generate sha1 keys
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android