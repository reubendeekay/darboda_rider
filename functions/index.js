const functions = require("firebase-functions");

const admin = require("firebase-admin");
var haversine = require("haversine-distance");

admin.initializeApp();

exports.getNearbyRider = functions.firestore
  .document("rides/{rideId}")
  .onCreate(async (snap, context) => {
    const onlineDrivers = await admin
      .firestore()
      .collection("riders")
      .where("isOnline", "==", true)
      .get();
    const ride = snap.data();
    //Check drivers within 10km

    //Sort drivers by distance
    onlineDrivers.docs.sort((driver1, driver2) => {
      const driver1Location = driver1.data().currentLocation;
      const driver2Location = driver2.data().currentLocation;
      const pickupLocation = ride.pickupLocation;

      //First point in your haversine calculation
      var point1 = {
        lat: currentLocation.latitude,
        lng: currentLocation.longitude,
      };

      //Second point in your haversine calculation
      var point2 = {
        lat: pickupLocation.latitude,
        lng: pickupLocation.longitude,
      };

      var haversine_m = haversine(point1, point2); //Results in meters (default)
      var haversine_km = haversine_m / 1000; //Results in kilometers

      return haversine_km - haversine_km;
    });

    //Get the closest driver
    for (let i = 0; i < onlineDrivers.docs.length; i++) {
      const closestDriver = onlineDrivers.docs[i];
      await admin.firestore().collection("rides").doc(ride.id).update({
        riderId: closestDriver.data().userId,
        rider: closestDriver.data(),
        riverLocation: closestDriver.data().currentLocation,
      });
      await admin
        .firestore()
        .collection("riders")
        .doc(closestDriver.data().userId)
        .update({
          rideId: ride.id,
        });

      const user = await admin
        .firestore()
        .collection("users")
        .doc(closestDriver.data().userId)
        .get();

      const payload = {
        notification: {
          title: "Incoming Request",
          body: `A new ride request has been made by ${ride.user.name}`,
          sound: "default",
        },
      };
      await admin.messaging().sendToDevice(userToken, payload);

      //sleep for 30 seconds
      await new Promise((resolve) => setTimeout(resolve, 30000));

      //Check if ride has been accepted
      const updatedRide = await admin
        .firestore()
        .collection("rides")
        .doc(ride.id)
        .get();
      if (updatedRide.data().status !== "pending") {
        return;
      } else {
        //Remove riderId from rider
        await admin

          .firestore()
          .collection("riders")
          .doc(closestDriver.data().userId)
          .update({
            rideId: "",
          });
      }
    }
  });

exports.sendRideNotifications = functions.firestore
  .document("rides/{rideId}")
  .onUpdate(async (snap, context) => {
    const ride = snap.after.data();
    const previousRide = snap.before.data();
    const user = await admin
      .firestore()
      .collection("users")
      .doc(ride.user.userId)
      .get();
    const userToken = user.data().pushToken;
    if (ride.status === "accepted" && previousRide.status !== "accepted") {
      const payload = {
        notification: {
          title: "Incoming Rider",
          body: `Your Darboda rider is on the way.`,
          sound: "default",
        },
      };
      await admin.messaging().sendToDevice(userToken, payload);
    }

    if (ride.status === "arrived" && previousRide.status !== "arrived") {
      const payload = {
        notification: {
          title: "Rider Arrived",
          body: `Your Darboda rider has arrived and is waiting for you.`,
          sound: "default",
        },
      };
      await admin.messaging().sendToDevice(userToken, payload);
    }

    if (ride.status === "completed" && previousRide.status !== "completed") {
      const payload = {
        notification: {
          title: "Trip Completed",
          body: `You have arrived at your destination and your ride is complete.`,
          sound: "default",
        },
      };
      await admin.messaging().sendToDevice(userToken, payload);
    }
    if (ride.status === "paid" && previousRide.status !== "paid") {
      const payload = {
        notification: {
          title: "Rate Your Ride",
          body: `Thank you for using Darboda. Please rate your ride.`,
          sound: "default",
        },
      };
      await admin.messaging().sendToDevice(userToken, payload);
    }
  });

// Send chat notifications
exports.sendChatNotifications = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const chat = await admin
      .firestore()
      .collection("chats")
      .doc(context.params.chatId)
      .get();
    const chatData = chat.data();
    const user = await admin
      .firestore()
      .collection("users")
      .doc(message.userId)
      .get();
    const userToken = user.data().pushToken;
    const payload = {
      notification: {
        title: user.data().name,
        body: `${user.data().name}: ${message.message}`,
        sound: "default",
      },
    };
    await admin.messaging().sendToDevice(userToken, payload);
  });
