# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: ApproveSnap Premium
- **Group ID**: ApproveSnap_Premium

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Pro Monthly
- **Product ID**: `com.zzoutuo.ApproveSnap.monthly`
- **Price**: $9.99 per month
- **Display Name**: ApproveSnap Pro Monthly
- **Description**: Unlimited projects and full audit trail
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: Pro Yearly
- **Product ID**: `com.zzoutuo.ApproveSnap.yearly`
- **Price**: $99.00 per year (17% savings vs monthly)
- **Display Name**: ApproveSnap Pro Yearly
- **Description**: Best value - save with annual billing
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: Lifetime Access
- **Product ID**: `com.zzoutuo.ApproveSnap.lifetime`
- **Price**: $199.99 one-time
- **Display Name**: ApproveSnap Lifetime
- **Description**: Pay once, use forever
- **Note**: Included as one-time purchase option for users who prefer no recurring billing

## Free Tier
- **Price**: Free
- **Limits**: 2 projects per month, basic approval, 7-day audit log
- **Included**: Approve/Reject, email notifications
- **Not Included**: Magic links, deadline reminders, full audit trail, version history, file attachments

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid monthly subscription)
- **Applies to**: Monthly subscription only

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Free trial terms included
- [ ] Restore purchases functionality implemented

## Pricing Rationale
- $9.99/mo is 80% cheaper than ApproveThis ($50/mo) and 47% cheaper than Markum ($19/mo)
- $99/yr = $8.25/mo, 17% discount encourages annual commitment
- $199.99 lifetime provides a no-recurring option for committed users
- Free tier with 2 projects/month allows full workflow experience before paywall
- Apple Small Business Program: 15% commission (not 30%)
