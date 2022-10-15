const functions = require("firebase-functions");

const admin = require("firebase-admin");
var haversine = require("haversine-distance");

admin.initializeApp();

exports.addIsBusyWhenRiderIsCreated = functions.firestore
  .document("riders/{riderId}")
  .onCreate(async (snap, context) => {
    const riderId = context.params.riderId;

    const isBusy = false;
    await admin

      .firestore()
      .collection("riders")
      .doc(riderId)
      .update({ isBusy: isBusy });
  });

exports.getNearbyRider = functions.firestore
  .document("rides/{rideId}")
  .onCreate(async (snap, context) => {
    const allAvailableDrivers = await admin
      .firestore()
      .collection("riders")
      .where("isBusy", "==", false)
      .get();
    const ride = snap.data();

    //get only riders whose isOnline is true
    const onlineDrivers = allAvailableDrivers.docs.filter(
      (doc) => doc.data().isOnline === true
    );
    //Check drivers within 10km

    //Sort drivers by distance
    onlineDrivers.sort((driver1, driver2) => {
      const driver1Location = driver1.data().currentLocation;
      const driver2Location = driver2.data().currentLocation;
      const pickupLocation = ride.pickupLocation;

      //First point in your haversine calculation
      var point1 = {
        lat: driver1Location.latitude,
        lng: driver1Location.longitude,
      };

      //Second point in your haversine calculation
      var point2 = {
        lat: pickupLocation.latitude,
        lng: pickupLocation.longitude,
      };

      var haversine_m = haversine(point1, point2); //Results in meters (default)
      var haversine_km = haversine_m / 1000; //Results in kilometers

      //First point in your haversine calculation
      var point3 = {
        lat: driver2Location.latitude,
        lng: driver2Location.longitude,
      };

      var haversine_m1 = haversine(point3, point2); //Results in meters (default)
      var haversine_km2 = haversine_m1 / 1000;

      //Sort by distance
      return haversine_km - haversine_km2;
    });

    //Get the closest driver
    for (let i = 0; i < onlineDrivers.length; i++) {
      const closestDriver = onlineDrivers[i];
      const previousClosestDriver = onlineDrivers[i - 1];
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
      const userToken = user.data().pushToken;

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
        await admin.firestore().collection("rides").doc(ride.id).update({
          riderId: null,
          rider: null,
          riverLocation: null,
        });
      }
      if (i == onlineDrivers.length - 1) {
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
          await admin
            .firestore()
            .collection("users")
            .doc(ride.user.userId)
            .update({
              rideId: "",
            });
          await admin.firestore().collection("rides").doc(ride.id).update({
            status: "failed",
          });
        }
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
          title: "Incoming Darboda rider",
          body: `Your Darboda rider is on the way.`,
          sound: "default",
        },
      };
      await admin.messaging().sendToDevice(userToken, payload);
      await admin
        .firestore()
        .collection("riders")
        .doc(ride.rider.userId)
        .update({
          isBusy: true,
        });
    }

    if (ride.status === "arrived" && previousRide.status !== "arrived") {
      const payload = {
        notification: {
          title: "Darboda Rider Arrived",
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

      await admin
        .firestore()
        .collection("riders")
        .doc(ride.rider.userId)
        .update({
          isBusy: false,
        });
    }
    if (ride.status === "cancelled" && previousRide.status !== "cancelled") {
      const rider = await admin
        .firestore()
        .collection("users")
        .doc(ride.rider.userId)
        .get();

      const riderToken = rider.data().pushToken;
      const payload = {
        notification: {
          title: "Trip Cancelled",
          body: `Your current trip has been cancelled.`,
          sound: "default",
        },
      };
      await admin.messaging().sendToDevice(userToken, payload);
      await admin.messaging().sendToDevice(riderToken, payload);
    }

    if (ride.status === "paid" && previousRide.status !== "paid") {
      //Add amount to userData
      const userData = await admin
        .firestore()
        .collection("userData")
        .doc(ride.rider.userId)
        .collection("payment")
        .doc("billing")
        .get();
      const newAmount =
        parseFloat(userData.data().totalAmount) + parseFloat(ride.amount);
      const newPendingAmount =
        parseFloat(userData.data().pendingAmount) +
        parseFloat(ride.amount) * 0.1;
      await admin
        .firestore()
        .collection("userData")
        .doc(ride.rider.userId)
        .collection("payment")
        .doc("billing")
        .update({
          totalAmount: newAmount.toString(),
          pendingAmount: newPendingAmount.toString(),
        });

      const payload = {
        notification: {
          title: "Rate Your Darboda Ride",
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
      .collection("messages")
      .doc(context.params.messageId)
      .get();
    const chatData = chat.data();
    const sentTo = await admin
      .firestore()
      .collection("users")
      .doc(chatData.to)
      .get();

    const sender = await admin
      .firestore()
      .collection("users")
      .doc(chatData.to)
      .get();
    const sentToToken = sentTo.data().pushToken;
    const payload = {
      notification: {
        title: "New Message from Darboda",

        body: `${sender.data().name}: ${message.message}`,
        sound: "default",
      },
      data: {
        icon: sender.data().photo,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        id: context.params.chatId,
        user: chatData.to,
      },
    };
    await admin.messaging().sendToDevice(sentToToken, payload);
  });

//A cron job running every 24 hours to get all userData collection where a doc has a field of nextPaymentDate and the value is greater than or equal to the current date
exports.sendPaymentNotifications = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    const allUserData = await admin.firestore().collection("userData").get();

    for (userData of allUserData.docs) {
      const specificUserData = await admin
        .firestore()
        .collection("userData")
        .doc(userData.id)
        .get();
      const nextPaymentDate = specificUserData.data().nextPaymentDate;
      const currentDate = new Date();
      if (nextPaymentDate >= currentDate) {
        await admin.firestore().collection("userData").doc(userData.id).update({
          isPending: true,
        });

        //Get user details
        const user = await admin
          .firestore()
          .collection("users")
          .doc(userData.id)
          .get();
        const userToken = user.data().pushToken;
        const payload = {
          notification: {
            title: "Payment Due",
            body: `Your weekly payment is due. Please make payment to continue using Darboda.`,
            sound: "default",
          },
        };
        await admin.messaging().sendToDevice(userToken, payload);
      }
    }
  });

//Manage online presence from Realtime database and sync it to Firestore rider collection
exports.manageOnlinePresence = functions.database
  .ref("/users/{userId}")
  .onUpdate(async (change, context) => {
    const user = change.after.val();
    const userId = context.params.userId;
    const userRef = admin.firestore().collection("riders").doc(userId);

    await userRef.update({
      isOnline: user.isOnline,
      lastSeen: user.lastSeen,
    });
  });
