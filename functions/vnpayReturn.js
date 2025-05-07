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

        const secretKey = process.env.VNPAY_SECRET_KEY;
        if (!secretKey) {
            console.error('Missing VNPay secret key');
            res.status(500).send("❌ Payment configuration error");
            return;
        }

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

            if (!txnRef) {
                console.error('Missing transaction reference');
                res.status(400).send("❌ Missing transaction reference");
                return;
            }

            try {
                await admin
                    .firestore()
                    .collection("orders")
                    .doc(txnRef)
                    .set({
                        paymentStatus: responseCode === "00" ? "success" : "failed",
                        vnpayResponse: req.query,
                        updatedAt: admin.firestore.FieldValue.serverTimestamp()
                    }, { merge: true });

                console.log(`✅ Payment result updated for order ${txnRef}`);
                res.send("✅ Payment result updated successfully");
            } catch (error) {
                console.error(`❌ Error updating order ${txnRef}:`, error);
                res.status(500).send("❌ Error updating order");
            }
        } else {
            console.error("❌ Invalid Signature");
            res.status(400).send("❌ Invalid signature");
        }
    } catch (error) {
        console.error("❌ Unexpected error:", error);
        res.status(500).send("❌ Internal server error");
    }
});