const functions = require("firebase-functions");
const crypto = require("crypto");
const admin = require("firebase-admin");

admin.initializeApp();

exports.vnpayReturn = functions.https.onRequest((req, res) => {
    const vnpParams = req.query;
    const secureHash = vnpParams["vnp_SecureHash"];

    delete vnpParams["vnp_SecureHash"];

    const secretKey = "5W7EUSKQRVFMWJHCDRWUAMM2WMN7AVVC";
    const sortedVnpParams = Object.keys(vnpParams)
        .sort()
        .reduce((obj, key) => {
            obj[key] = vnpParams[key];
            return obj;
        }, {});

    const querystring = require("qs");
    const signData = querystring.stringify(sortedVnpParams, { encode: false });
    const hmac = crypto.createHmac("sha512", secretKey);
    const signed = hmac.update(new Buffer(signData, "utf-8")).digest("hex");

    if (secureHash === signed) {
        // Kiểm tra chữ ký thành công
        const responseCode = vnpParams["vnp_ResponseCode"];
        const txnRef = vnpParams["vnp_TxnRef"];

        // Cập nhật trạng thái đơn hàng trong Firestore
        admin
            .firestore()
            .collection("orders")
            .doc(txnRef)
            .update({
                paymentStatus: responseCode === "00" ? "success" : "failed",
                vnpayResponse: vnpParams,
            })
            .then(() => {
                res.send("Payment result updated successfully");
            })
            .catch((error) => {
                console.error("Error updating order:", error);
                res.status(500).send("Error updating order");
            });
    } else {
        // Chữ ký không hợp lệ
        res.status(400).send("Invalid signature");
    }
});
