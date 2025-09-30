<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Ride;
use App\Models\PaymentMethod;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PaymentController extends Controller
{
    /**
     * Get user's payment methods
     */
    public function getPaymentMethods(Request $request)
    {
        $user = $request->user();
        
        $paymentMethods = PaymentMethod::where('user_id', $user->id)
            ->where('is_active', true)
            ->get()
            ->map(function ($method) {
                return [
                    'id' => $method->id,
                    'type' => $method->type,
                    'last_four' => $method->details['last_four'] ?? '****',
                    'brand' => $method->details['brand'] ?? 'unknown',
                    'is_default' => $method->is_default,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $paymentMethods
        ]);
    }

    /**
     * Add a new payment method
     */
    public function addPaymentMethod(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|string|in:card,wallet,bank',
            'details' => 'required|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = $request->user();

        // If this is the first payment method, make it default
        $isDefault = PaymentMethod::where('user_id', $user->id)->count() === 0;

        $paymentMethod = PaymentMethod::create([
            'user_id' => $user->id,
            'type' => $request->type,
            'details' => $request->details,
            'is_default' => $isDefault,
            'is_active' => true,
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $paymentMethod->id,
                'type' => $paymentMethod->type,
                'details' => $paymentMethod->details,
                'is_default' => $paymentMethod->is_default,
            ],
            'message' => 'Payment method added successfully'
        ]);
    }

    /**
     * Process payment for a ride
     */
    public function processPayment(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ride_id' => 'required|exists:rides,id',
            'payment_method_id' => 'required|string',
            'amount' => 'required|numeric|min:0.01',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = $request->user();
        $ride = Ride::find($request->ride_id);

        // Verify ride belongs to user
        if ($ride->rider_id !== $user->id) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized access to ride'
            ], 403);
        }

        // Mock payment processing - in production, integrate with payment gateway
        $paymentId = 'PAY_' . time() . '_' . rand(1000, 9999);
        
        // Update ride payment status
        $ride->update([
            'payment_status' => 'paid',
            'final_fare' => $request->amount,
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'payment_id' => $paymentId,
                'amount' => $request->amount,
                'status' => 'completed',
                'ride_id' => $ride->id,
            ],
            'message' => 'Payment processed successfully'
        ]);
    }

    /**
     * Get wallet balance
     */
    public function getWalletBalance(Request $request)
    {
        $user = $request->user();
        
        $wallet = Wallet::firstOrCreate(
            ['user_id' => $user->id],
            ['balance' => 0, 'currency' => 'PKR']
        );

        return response()->json([
            'success' => true,
            'data' => [
                'balance' => $wallet->balance,
                'currency' => $wallet->currency,
            ]
        ]);
    }

    /**
     * Add money to wallet
     */
    public function addToWallet(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:1',
            'payment_method_id' => 'required|exists:payment_methods,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = $request->user();
        $amount = $request->amount;

        DB::beginTransaction();
        try {
            // Get or create wallet
            $wallet = Wallet::firstOrCreate(
                ['user_id' => $user->id],
                ['balance' => 0, 'currency' => 'PKR']
            );

            // Create transaction record
            $transaction = Transaction::create([
                'user_id' => $user->id,
                'type' => 'wallet_topup',
                'amount' => $amount,
                'currency' => 'PKR',
                'description' => 'Wallet top-up',
                'reference_id' => 'TXN_' . time() . '_' . rand(1000, 9999),
                'status' => 'completed',
                'payment_method_id' => $request->payment_method_id,
            ]);

            // Update wallet balance
            $wallet->increment('balance', $amount);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'transaction_id' => $transaction->reference_id,
                    'amount' => $amount,
                    'new_balance' => $wallet->fresh()->balance,
                    'status' => 'completed',
                ],
                'message' => 'Money added to wallet successfully'
            ]);
        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'error' => 'Failed to add money to wallet: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get transaction history
     */
    public function getTransactionHistory(Request $request)
    {
        $user = $request->user();
        
        $transactions = Transaction::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get()
            ->map(function ($transaction) {
                return [
                    'id' => $transaction->id,
                    'type' => $transaction->type,
                    'amount' => $transaction->amount,
                    'description' => $transaction->description,
                    'status' => $transaction->status,
                    'created_at' => $transaction->created_at->toISOString(),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $transactions
        ]);
    }
}
