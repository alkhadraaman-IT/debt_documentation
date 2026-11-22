# Contract: Ledger Entries & Balance

## 1. Business Rules
- Entry Types:
  - loan: A full debt. The creator paid for the partner. calculatedSplitMinor = amountMinor.
  - split_expense: A shared 50/50 expense. calculatedSplitMinor = (amountMinor / 2).ceil().
- Statuses:
  - pending: Awaiting partner confirmation. Does not affect the official balance.
  - confirmed: Partner approved. Affects the official balance.
  - rejected: Partner declined. Requires a reason.
  - reversed: Creator cancelled a confirmed entry. Requires a reason. Affects balance negatively (reversal).
- Immutability: Confirmed entries CANNOT be edited. To fix a mistake, the creator must reverse the confirmed entry and create a new one.
- Connectivity:
  - Creating an entry (pending) is allowed offline.
  - Confirming, rejecting, or reversing an entry REQUIRES internet connectivity.
  - Requesting or approving ledger closure REQUIRES internet connectivity.

## 2. Firestore Data Model

### ledgers/{ledgerId}
- currentBalanceMinor: int (Net balance, updated ONLY when an entry is confirmed/reversed).
- pendingEntriesCount: int (Number of entries with status 'pending'. Used to block ledger closure).

### ledgers/{ledgerId}/entries/{entryId}
- entryId: string
- amountMinor: int (> 0)
- calculatedSplitMinor: int (Half rounded up, or full amount depending on type)
- entryType: 'loan' | 'split_expense'
- status: 'pending' | 'confirmed' | 'rejected' | 'reversed'
- createdBy: string (uid)
- version: int (starts at 1)

## 3. Balance Calculation Logic (in Data Layer Transaction)
When changing an entry status from pending to confirmed:
- If entryType == 'loan': ledger.currentBalanceMinor += entry.amountMinor
- If entryType == 'split_expense': ledger.currentBalanceMinor += entry.calculatedSplitMinor
- ledger.pendingEntriesCount -= 1

When reversing a confirmed entry:
- If entryType == 'loan': ledger.currentBalanceMinor -= entry.amountMinor
- If entryType == 'split_expense': ledger.currentBalanceMinor -= entry.calculatedSplitMinor

## 4. Ledger Closure Rules
- Cannot request closure if ledger.pendingEntriesCount > 0.
- The finalBalanceMinor sent in the closing request MUST match ledger.currentBalanceMinor. Firestore rules must enforce this exact match.