class UserProfile {
  String email;
  String uid;
  String name;
  String age;
  List<String> interests;
  String photoURL;
  String phoneNumber;
  String shortDescription;

  UserProfile(
      {String name = '',
      String email = '',
      List<String> interests = const [''],
      String photoURL = '',
      String phoneNumber = '',
      String age = '',
      String uid = '',
      // prepopulated with this text but will show interests if any are set
      String shortDescription = 'Hi I\m new here :)'}) {
    this.shortDescription = shortDescription;
    this.email = email;
    this.age = age;
    this.uid = uid;
    this.interests = interests;
    this.name = name;
    this.photoURL = photoURL;
    this.phoneNumber = phoneNumber;
  }
}
