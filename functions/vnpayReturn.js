const { onRequest } = require("firebase-functions/v2/https");
const crypto = require("crypto");
const admin = require("firebase-admin");
const querystring = require("qs");

admin.initializeApp();

exports.vnpayReturn = onRequest({
    cors: true,
    maxInstances: 10,
    memory: "256MiB",
    timeoutSeconds: 60,
}, async (req, res) => {
    try {
        const vnpParams = { ...req.query };
        const secureHash = vnpParams["vnp_SecureHash"];

        if (!secureHash) {
            console.error('Missing secure hash');
            res.status(400).send("❌ Missing secure hash");
            return;
        }

        delete vnpParams["vnp_SecureHash"];
        delete vnpParams["vnp_SecureHashType"];

        const secretKey = "5W7EUSKQRVFMWJHCDRWUAMM2WMN7AVVC";
        const sortedVnpParams = Object.keys(vnpParams)
            .sort()
            .reduce((obj, key) => {
                obj[key] = vnpParams[key];
                return obj;
            }, {});

        const signData = querystring.stringify(sortedVnpParams, { encode: false });
        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

        if (secureHash === signed) {
            const responseCode = vnpParams["vnp_ResponseCode"];
            const txnRef = vnpParams["vnp_TxnRef"];

            await admin.firestore().collection("orders").doc(txnRef).set({
                paymentStatus: responseCode === "00" ? "success" : "Failed",
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            }, { merge: true });

            console.log(`✅ Payment result updated for order ${txnRef}`);
            res.send("✅ Payment result updated successfully");
        } else {
            console.error("❌ Invalid Signature");
            res.status(400).send("❌ Invalid signature");
        }
    } catch (error) {
        console.error("❌ Unexpected error:", error);
        res.status(500).send("❌ Internal server error");
    }
});
