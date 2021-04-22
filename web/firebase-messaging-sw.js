importScripts("https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyAxA9TYlDVEUp0t9R3vt8kDykYx6-bOwfY",
  authDomain: "activitiesinyourarea-500ef.firebaseapp.com",
  databaseURL: "https://activitiesinyourarea-500ef-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "activitiesinyourarea-500ef",
  storageBucket: "activitiesinyourarea-500ef.appspot.com",
  messagingSenderId: "324776373375",
  appId: "1:324776373375:web:4d69d07706aa954c2ce34a",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});