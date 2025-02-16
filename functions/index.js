const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.matchFoodRequests = functions.firestore
    .document("food_uploads/{uploadId}")
    .onCreate(async (snap, context) => {
      const uploadedFood = snap.data();
      const foodQuantity = uploadedFood.quantity;
      const uploadId = context.params.uploadId;

      const requestsRef = admin.firestore().collection("food_requests");
      const requestsSnapshot = await requestsRef
          .where("status", "==", "Pending")
          .where("quantityRequired", "<=", foodQuantity)
          .limit(1)
          .get();

      if (!requestsSnapshot.empty) {
        const matchingRequest = requestsSnapshot.docs[0];
        const consumerId = matchingRequest.data().consumerId;

        // Update request and food status
        await requestsRef.doc(matchingRequest.id).update({
          status: "Matched",
          matchedFoodId: uploadId
        });

        await admin.firestore().collection("food_uploads").doc(uploadId).update({
          status: "Matched",
          matchedConsumerId: consumerId
        });

        // Send notification
        const payload = {
          notification: {
            title: "Food Available!",
            body: `A food donation matching your request is available.`,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          token: consumerId // Assuming FCM Token is stored in consumer profile
        };

        await admin.messaging().send(payload);
      }
    });
