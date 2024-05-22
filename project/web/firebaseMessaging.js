importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "AIzaSyAM_K2axMH_vb2JJdadwJGr5JWQXTifwOA",
  authDomain: "mobile2-b7914.firebaseapp.com",
  databaseURL: "https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "mobile2-b7914",
  storageBucket: "mobile2-b7914.appspot.com",
  messagingSenderId: "820320428284",
  appId: "1:820320428284:web:86ff19f46e8f1c8f79f779",
  measurementId: "G-P5RVSDGQJT"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/firebase-logo.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
