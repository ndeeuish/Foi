const functions = require("firebase-functions");
//const request = require("request");
const moment = require("moment");
const crypto = require("crypto");

exports.createVNPayPayment = functions.https.onRequest((req, res) => {
    const ipAddr = req.headers["x-forwarded-for"] || req.connection.remoteAddress;

    const tmnCode = "NO2W1JM9"; 
    const secretKey = "5W7EUSKQRVFMWJHCDRWUAMM2WMN7AVVC"; 
    const vnpUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    const returnUrl = "https://vnpayreturn-fi5yhlbyqq-uc.a.run.app";
    const orderId = moment().format("YYYYMMDDHHmmss");
    const amount = req.body.amount; // Lấy số tiền từ request
    const orderInfo = "Thanh toan don hang " + orderId;
    const createDate = moment().format("YYYYMMDDHHmmss");

    const vnpParams = {};
    vnpParams["vnp_Version"] = "2.1.0";
    vnpParams["vnp_Command"] = "pay";
    vnpParams["vnp_TmnCode"] = tmnCode;
    vnpParams["vnp_Amount"] = amount * 100;
    vnpParams["vnp_CurrCode"] = "VND";
    vnpParams["vnp_TxnRef"] = orderId;
    vnpParams["vnp_OrderInfo"] = orderInfo;
    vnpParams["vnp_ReturnUrl"] = returnUrl;
    vnpParams["vnp_IpAddr"] = ipAddr;
    vnpParams["vnp_CreateDate"] = createDate;

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
    vnpParams["vnp_SecureHash"] = signed;
    const paymentUrl =
        vnpUrl + "?" + querystring.stringify(vnpParams, { encode: false });

    res.json({ paymentUrl: paymentUrl });
});
