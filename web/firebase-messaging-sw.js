importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js");

// ✅ Initialize Firebase inside the service worker
firebase.initializeApp({
    apiKey: 'AIzaSyBFh1OSIzXrTdmm4H_fzQIa1mrF8H3clnc',
    appId: '1:554788460660:web:798e221c1950fef5f19921',
    messagingSenderId: '554788460660',
    projectId: 'food-management-app-ff8df',
    authDomain: 'food-management-app-ff8df.firebaseapp.com',
    storageBucket: 'food-management-app-ff8df.firebasestorage.app',
});

// ✅ Retrieve Firebase Messaging
const messaging = firebase.messaging();

// ✅ Handle Background Messages
messaging.onBackgroundMessage((payload) => {
    console.log("Received background message: ", payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: "/firebase-logo.png",
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
