const functions = require('firebase-functions');
const stripe = require('stripe')('sk_test_51RLzzs2KB6w1OIx4J9Pf0bP3kj31AKaoJFQgawh8BEmhSOy5fhn0258NEvsIRXq7YPnzoJK71MvGxf4AO6P0f83Y00L58YScIB');

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