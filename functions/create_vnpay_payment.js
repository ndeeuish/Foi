const functions = require('firebase-functions');
const crypto = require('crypto');
const moment = require('moment-timezone');
const cors = require('cors')({ origin: true }); // Import và cấu hình CORS

exports.createVnpayPayment = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
        try {
            const vnp_TmnCode = "NO2W1JM9";
            const vnp_HashSecret = "5W7EUSKQRVFMWJHCDRWUAMM2WMN7AVVC";
            const vnp_Url = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
            const vnp_ReturnUrl = "https://vnpayreturn-fi5yhlbyqq-uc.a.run.app";

            const vnp_Version = "2.1.0";
            const vnp_Command = "pay";
            const vnp_Locale = "vn";
            const vnp_CurrCode = "VND";
            const vnp_TxnRef = moment().format('YYYYMMDDHHmmss');
            const vnp_OrderInfo = req.query.orderInfo || "Thanh toan don hang";
            const vnp_Amount = parseInt(req.query.amount) * 100;
            const vnp_IpAddr = req.ip;
            const vnp_CreateDate = moment().tz('Asia/Ho_Chi_Minh').format('YYYYMMDDHHmmss');
            const vnp_OrderType = "other";
            const vnp_ExpireDate = moment().tz('Asia/Ho_Chi_Minh').add(15, 'minutes').format('YYYYMMDDHHmmss');

            const vnp_Params = {};
            vnp_Params['vnp_Version'] = vnp_Version;
            vnp_Params['vnp_Command'] = vnp_Command;
            vnp_Params['vnp_TmnCode'] = vnp_TmnCode;
            vnp_Params['vnp_Locale'] = vnp_Locale;
            vnp_Params['vnp_CurrCode'] = vnp_CurrCode;
            vnp_Params['vnp_TxnRef'] = vnp_TxnRef;
            vnp_Params['vnp_OrderInfo'] = vnp_OrderInfo;
            vnp_Params['vnp_Amount'] = vnp_Amount;
            vnp_Params['vnp_ReturnUrl'] = vnp_ReturnUrl;
            vnp_Params['vnp_IpAddr'] = vnp_IpAddr;
            vnp_Params['vnp_CreateDate'] = vnp_CreateDate;
            vnp_Params['vnp_OrderType'] = vnp_OrderType;
            vnp_Params['vnp_ExpireDate'] = vnp_ExpireDate;

            const sortedVnpParams = Object.keys(vnp_Params)
                .sort()
                .reduce((obj, key) => {
                    obj[key] = vnp_Params[key];
                    return obj;
                }, {});

            const query = Object.keys(sortedVnpParams)
                .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(sortedVnpParams[key])}`)
                .join('&');

            const hmac = crypto.createHmac('sha512', vnp_HashSecret);
            const signed = hmac.update(Buffer.from(query, 'utf-8')).digest('hex');

            const paymentUrl = `${vnp_Url}?${query}&vnp_SecureHashType=SHA512&vnp_SecureHash=${signed}`;

            res.json({ paymentUrl });
            console.log("Payment URL:", paymentUrl);

        } catch (error) {
            console.error("Lỗi tạo URL thanh toán:", error);
            res.status(500).send("Lỗi khi tạo URL thanh toán");
        }
    });
});