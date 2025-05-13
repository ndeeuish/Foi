const { onRequest } = require("firebase-functions/v2/https");
const moment = require("moment");
const crypto = require("crypto");
const querystring = require("qs");

// Helper function to sort object keys
function sortObject(obj) {
    const sorted = {};
    Object.keys(obj).sort().forEach(key => {
        sorted[key] = obj[key];
    });
    return sorted;
}

exports.createVNPayPayment = onRequest({
    cors: true,
    maxInstances: 10,
    memory: "256MiB",
    timeoutSeconds: 60,
}, async (req, res) => {
    try {
        // Validate request method
        if (req.method !== 'POST') {
            res.status(405).json({ error: 'Method not allowed' });
            return;
        }

        // Validate amount
        const amount = parseFloat(req.body.amount);
        if (!amount || amount <= 0) {
            res.status(400).json({ error: 'Invalid amount' });
            return;
        }

        const ipAddr = req.headers["x-forwarded-for"] || req.connection.remoteAddress;
        const tmnCode = "NO2W1JM9"; 
        const secretKey = "5W7EUSKQRVFMWJHCDRWUAMM2WMN7AVVC"; 
        const vnpUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
        const returnUrl = "https://vnpayreturn-fi5yhlbyqq-uc.a.run.app";
        
        if (!tmnCode || !secretKey || !returnUrl) {
            console.error('Missing VNPay configuration');
            res.status(500).json({ error: 'Payment configuration error' });
            return;
        }

        const orderId = moment().format("HHmmss");
        const orderInfo = "Thanh toan don hang " + orderId;
        const createDate = moment().format("YYYYMMDDHHmmss");

        // Create params
        const vnpParams = {
            vnp_Amount: Math.round(amount * 100),
            vnp_Command: "pay",
            vnp_CreateDate: createDate,
            vnp_CurrCode: "VND",
            vnp_IpAddr: ipAddr,
            vnp_Locale: "vn",
            vnp_OrderInfo: orderInfo,
            vnp_OrderType: "other",
            vnp_ReturnUrl: returnUrl,
            vnp_TmnCode: tmnCode,
            vnp_TxnRef: orderId,
            vnp_Version: "2.1.0"
        };

        // Sort params
        const sortedVnpParams = sortObject(vnpParams);

        // Create signature string (without encoding)
        const signData = querystring.stringify(sortedVnpParams, { 
            encode: false 
        });
        console.log('SignData:', signData);

        // Create signature
        const hmac = crypto.createHmac("sha512", secretKey);
        const signed = hmac.update(new Buffer(signData, 'utf-8')).digest("hex");
        console.log('Signed:', signed);
        
        // Add signature to params
        sortedVnpParams.vnp_SecureHash = signed;

        // Create payment URL
        const paymentUrl = vnpUrl + "?" + querystring.stringify(sortedVnpParams, {
            encode: true
        });
        console.log('Payment URL:', paymentUrl);

        res.json({ paymentUrl });
    } catch (error) {
        console.error('Error creating VNPay payment:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});