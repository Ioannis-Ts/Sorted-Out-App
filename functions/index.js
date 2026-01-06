const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * 🔁 Monthly reset of totalpoints
 * Runs every 1st day of the month at 00:00 (UTC)
 */
exports.resetMonthlyPoints = functions.pubsub
  .schedule("0 0 1 * *")
  .timeZone("Europe/Athens")
  .onRun(async (context) => {
    const db = admin.firestore();

    console.log("Starting monthly points reset...");

    const profilesSnap = await db.collection("Profiles").get();

    if (profilesSnap.empty) {
      console.log("No profiles found.");
      return null;
    }

    const batch = db.batch();
    let count = 0;

    profilesSnap.forEach((doc) => {
      const ref = doc.ref;
      batch.update(ref, { totalpoints: 0 });
      count++;
    });

    await batch.commit();

    console.log(`Reset totalpoints for ${count} profiles.`);
    return null;
  });
 
