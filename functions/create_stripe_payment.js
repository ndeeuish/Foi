const functions = require('firebase-functions');
const stripe = require('stripe')(functions.config().stripe.secret);

exports.createStripePayment = functions.https.onCall(async (data, context) => {
  try {
    // Verify authentication
    if (!context.auth) {
      throw new Error('Unauthorized');
    }

    const { amount } = data;
    if (!amount || amount <= 0) {
      throw new Error('Invalid amount');
    }

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency: 'vnd',
      payment_method_types: ['card'],
      metadata: {
        userId: context.auth.uid,
      },
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    console.error('Error creating payment:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
}); 