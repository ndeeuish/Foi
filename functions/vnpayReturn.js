const functions = require("firebase-functions");
const crypto = require("crypto");
const admin = require("firebase-admin");
const querystring = require("qs");

admin.initializeApp();

exports.vnpayReturn = functions.https.onRequest((req, res) => {
    const vnpParams = { ...req.query };
    const secureHash = vnpParams["vnp_SecureHash"];

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

        admin
            .firestore()
            .collection("orders")
            .doc(txnRef)
            .set({
                paymentStatus: responseCode === "00" ? "success" : "failed",
                vnpayResponse: req.query,
            }, { merge: true })
            .then(() => {
                res.send("✅ Payment result updated successfully");
            })
            .catch((error) => {
                console.error("❌ Error updating order:", error);
                res.status(500).send("❌ Error updating order");
            });
    } else {
        console.log("❌ Invalid Signature");
        res.status(400).send("❌ Invalid signature");
    }
});