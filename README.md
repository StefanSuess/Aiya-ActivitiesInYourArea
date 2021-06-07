<h1 align="center">Welcome to Aiya - Activties In Your Area</h1>
<p align="center">
  <a href="https://github.com/StefanSuess/Bsc-Project-Aiya"><img alt="GitHub license" src="https://img.shields.io/github/license/StefanSuess/Bsc-Project-Aiya"></a>
  <a href="https://github.com/StefanSuess/Bsc-Project-Aiya/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/StefanSuess/Bsc-Project-Aiya"></a>
</p>

<p align="center">
<img src="https://user-images.githubusercontent.com/50103762/121037878-1d9e0980-c7b0-11eb-8974-94fabd315d21.gif" alt="Device Example Video" width="135" height="292,5">
<img src="https://user-images.githubusercontent.com/50103762/121043495-fac22400-c7b4-11eb-9b89-222f5f61c21f.png" alt="Login Screen" width="400" height="400">
<img src="https://user-images.githubusercontent.com/50103762/121053384-948ccf80-c7bb-11eb-90dc-6853bd2b9de1.gif" alt="Device Example Video" width="135" height="292,5">
</p>

> Aiya is an app for Android, Web and iOS, developed with Flutter, which allows you to find, create and join user created activities in real life.

##### Features:

- Create activities (where, when, what, more information)
- Search for activities (and order by date, location or title)
- Request to join activities
- Permit or deny join requests
- User Profile (picture, name, age, email, phone, interests, contact
  options)
- Share functionality with <a
  href="https://flutter.dev/docs/development/ui/navigation/deep-linking">deeplinks</a>
- Group chat functionality with image support
- Some nice animations (especially dashboard to profile animation)
- Dashboard (shows join requests, created activities and joined
  activities)

##### Tested on:

- iOS simulator (iOS 14) *iOS version is not thoroughly tested*
- MI 9T Android phone (Android 10)
- Pixel 4 emulator (Android 11)
- Google chrome mobile
- Firefox mobile

##### Technology used:

- Flutter 2.2
- Firebase (spark and blaze plan)
- Android Studio
- VS Code (for cloud functions)

##### Interesting stuff

- Provider pattern used
- Hero animation with cached images (data on frame one)
- Basic integration of unsplash api (activity title = keyword for
  activity picture)
- This app was developed during the covid pandemic and thus has a
  warning and link to the WHO covid page


##### TODO

- [ ] Write tests
- [ ] Implement a filter to block inappropriate words and images
      (probably via Firebase ML)
- [ ] Reduce and streamline API requests (at the moment every widget
      calls the api itself instead of one time at the creation of the
      screen)
- [ ] Refactor and comment code to make it more readable and
      understandable


## Installation

Aiya uses Firebase as the backend, thus it is required to setup a free
Firebase account. **All functions of Aiya are available in the free tier
of Firebase except push messages.**

### The Backend (Firebase)

#### Step 1

Create an account at <a
href="https://firebase.google.com/">firebase.google.com</a>, or login to
an existing account.

#### Step 2

<a href="https://console.firebase.google.com/">Create a new Project</a>
and follow the on-screen instructions.

#### Step 3

Add an <a
href="https://firebase.flutter.dev/docs/installation/android/">Android</a>,
<a href="https://firebase.flutter.dev/docs/installation/ios/">IOS</a> or
<a href="https://firebase.flutter.dev/docs/installation/web/">Web</a>
app<br> *The android package name of this app is ``com.example.aiya``*

#### Here is an example for Android:

*Excerpt from
``https://firebase.flutter.dev/docs/installation/android/``*

***

On the Firebase Console, add a new Android app or select an existing
Android app for your Firebase project.\ The "Android package name" must
match your local project's package name that was created when you
started the Flutter project. The current package name can be found in
your module (app-level) Gradle file, usually android/app/build.gradle,
defaultConfig section (example package name:
com.yourcompany.yourproject).

>When creating a new Android app "debug signing certificate SHA-1" is
>optional, however, it is required for Dynamic Links & Phone
>Authentication. To generate a certificate run cd android && ./gradlew
>signingReport and copy the SHA1 from the debug key. This generates two
>variant keys. You can copy the 'SHA1' that belongs to the
>debugAndroidTest variant key option.

Once your Android app has been registered, download the configuration
file from the Firebase Console (the file is called
google-services.json). Add this file into the android/app directory
within your Flutter project.

#### Step 4

##### To activate sign in and register methods (Authentication)

1. In the Firebase console navigate to Authentication -> Sign-in method
2. Activate Email/Password (and optionally Google)

##### To enable the creation of activities (Firestore)

1. In the Firebase console navigate to Firestore Database --> Create
   Database
2. Click on either production mode or test mode


### The Frontend (the app itself)

#### Step 1

Download or clone this repo by using the link below:

```sh
https://github.com/StefanSuess/Aiya-ActivitiesInYourArea.git
```

#### Step 2

Go to project root and execute the following command in the console to
get the required dependencies:

```sh
flutter pub get
```

## Run (debug version)

You can either select a device via your IDEs GUI or run the following
commands in the terminal, inside the projects root directory.

#### Web

Google Chrome needs to be installed.

```sh
flutter run -d chrome
```

#### Android

First open your Android emulator or connect your Android phone.

```sh
flutter run
```

#### iOS

Only works on MacOS, XCode needs to be installed.

```sh
open -a simulator
flutter run
```

## Build (release version)

#### Web

```sh
flutter build web
```

You can find the files after the build completes at
```<ProjectRoot>/build/web/```. For more information how to host your
web app see <a href="https://flutter.dev/docs/deployment/web">Build and
release a web app</a>.

#### Android

```sh
flutter build apk
```

You can find the .apk at
```<ProjectRoot>/build/app/outputs/flutter-apk/```.

#### iOS

Only works on MacOS, XCode needs to be installed.

```sh
flutter build ipa
```


## Author

👤 **Stefan Suess**

* Website: https://www.linkedin.com/in/stefansuess
* Github: [@StefanSuess](https://github.com/StefanSuess)
* LinkedIn: [@stefansuess](https://linkedin.com/in/stefansuess)

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2021 [Stefan Suess](https://github.com/StefanSuess).<br />
This project is [MIT](https://opensource.org/licenses/MIT) licensed.
