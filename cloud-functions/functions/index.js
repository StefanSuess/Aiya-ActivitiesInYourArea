const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

// sends a notification to the activity creator if someone wants to join
exports.sendJoinRequestNotification = functions.firestore.document('/activities/{activityID}')
    .onUpdate(async (change, context) => {

        // get the activity ID
        const activityID = context.params.activityID;
        // get the activity creator ID because he will be sent an notification
        const creatorUID = change.after.data().creatorUID;
        // get activity title for notification
        const activityTitle = change.after.data().title;

        const joinRequestsBefore = change.before.data().joinRequests;
        const joinRequestsAfter = change.after.data().joinRequests;

        // compare lengths, if before is longer than after then a user was deleted and thus no notification should be sent
        if (joinRequestsBefore.length >= joinRequestsAfter.length) {
            return null;
        }

        // get user profile of activity creator
        const activityCreatorProfile = await admin.firestore().collection('users').doc(creatorUID).get();
        // get notificationToken of activity creator
        const activityCreatorNotificationToken = activityCreatorProfile.get('notificationToken');

        //console.log('CreatorNotificationToken: ' + activityCreatorNotificationToken);

        // Notification details.
        const payload = {
            notification: {
                title: 'Someone requested to join ' + String(activityTitle),
                body: `You can find more information under Dashboard -> Notifications :)`,
            },
            data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                screen: 'dashboard',
            }
        };

        // Send notifications to all tokens.
        const response = await admin.messaging().sendToDevice(activityCreatorNotificationToken, payload);
        // Maybe test if token is currently being used but not really necessery because token will be set everytime a user creates and activity or sends a join request
    });


// sends a notification to the person who was accepted
exports.sendJoinAcceptNotification = functions.firestore.document('/activities/{activityID}')
    .onUpdate(async (change, context) => {

        // get activity title for notification
        const activityTitle = change.after.data().title;
        const activity = change.after.data();

        const joinAcceptsBefore = change.before.data().joinAccept;

        const joinAcceptsAfter = change.after.data().joinAccept;

        // compare lengths, if before is longer than after then a user was deleted and thus no notification should be sent
        if (joinAcceptsBefore.length >= joinAcceptsAfter.length) {
            return null;
        }

        // find the latest UID in the accepted join requests (it should be the last one because it was newly added)
        const newlyJoinedUserUID = joinAcceptsAfter[joinAcceptsAfter.length - 1];
        console.log(newlyJoinedUserUID);

        // get user profile of the user whos join request was accepted (newly joined)
        const newlyJoinedUser = await admin.firestore().collection('users').doc(newlyJoinedUserUID).get();
        // get notificationToken of activity creator
        const newlyJoinedUserNotificationToken = newlyJoinedUser.get('notificationToken');

        console.log(activityTitle);
        // Notification details.
        const payload = {
            notification: {
                title: 'Your request to join ' + String(activityTitle) + ' was accepted',
                body: 'You can find more information under Dashboard -> Joined :)',
            }, data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                screen: 'activityDetail',
                activity: activityID,
            }
        };

        // Send notifications to all tokens.
        const response = await admin.messaging().sendToDevice(newlyJoinedUserNotificationToken, payload);
        // Maybe test if token is currently being used but not really necessery because token will be set everytime a user creates and activity or sends a join request
    });

exports.sendGroupMessageNotification = functions.firestore.document('/groupchats/{activityID}/messages/{message}')
    .onCreate(async (change, context) => {

        // get activity title for notification
        const activityID = context.params.activityID;
        const activity = await admin.firestore().collection('activities').doc(activityID).get();
        const messageData = change.data().content;
        const messageType = change.data().type;
        const messageFrom = change.data().idFrom;

        // Notification details.
        const payload = {
            notification: {
                title: 'Groupchat new message in: ' + activity.get('title'),
                body: messageData,
            }, data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                screen: 'activityDetail',
                activity: activityID,
            }
        };

        // get list of users 
        let subscribedUsers = activity.get('joinAccept');
        console.log('JOINACCEPT: ', subscribedUsers);
        const activityCreator = activity.get('creatorUID');
        console.log('CREATORID: ', activityCreator);
        subscribedUsers.unshift(activityCreator);

        console.log('SUBSCRIBEDUSERS: ', subscribedUsers);

        if (subscribedUsers.length < 1) {
            return null;
        }

        // remove current user
        subscribedUsers = subscribedUsers.filter(item => item !== messageFrom);
        console.log('SUBSCRIBEDUSERS2:', subscribedUsers);

        const userTokens = [''];

        subscribedUsers.forEach(async (element) => {
            const userToken = await admin.firestore().collection('users').doc(element).get();
            const notificationToken = userToken.get('notificationToken');
            console.log('USERTOKEN: ', notificationToken);
            if (notificationToken != null) {
                admin.messaging().sendToDevice(notificationToken, payload);
            }
        });

        // Send notifications to all tokens.

        // Maybe test if token is currently being used but not really necessery because token will be set everytime a user creates and activity or sends a join request
    });