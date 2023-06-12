/+  *zig-sys-smart
|%
::
::  Starting with 5 minutes to test
++  rewards-duration 300
::
++  our-fungible-contract
  0x7abb.3cfe.50ef.afec.95b7.aa21.4962.e859.87a0.b22b.ec9b.3812.69d3.296b.24e1.d72a
::
++  staking-token-contract
  0x74.6361.7274.6e6f.632d.7367.697a  ::  starting with zigs for now
::
++  dec-18  1.000.000.000.000.000.000
::  data types
+$  distributor
  $:  staking-token=[meta=id contract=id amount=@ud]
      reward-token=[meta=id contract=id amount=@ud] ::  in this case does amount just track amount minted?
      period-finish=@ud  ::  inits with 0
      reward-rate=@ud  ::  (reward-amount / rewards-duration)
      reward-duration=@ud  ::  period length in seconds
      last-update-time=@ud
      reward-per-token-stored=@ud  ::  updated by adding (lastRewardApplicable - lastUpdateTime * rewardRate / totalSupply)
      user-reward-per-token-paid=(pmap address @ud)
      rewards=(pmap address @ud)  ::  tracks what each staker is owed
      total-supply=@ud  ::  total amount of staking token staked
      balances=(pmap address @ud)  ::  tracks how much each staker has staked
      distributor-reward-balance=@ud  ::  to limit rewards per period
  ==
::
+$  token-args
  $:  meta=id
      amount=@ud
      from-account=id
  ==
::  from fungible standard
+$  token-account
  $:  balance=@ud
      allowances=(pmap address @ud)
      metadata=id
      nonces=(pmap address @ud)
  ==
::  %pull signed token approval
+$  approval  [nonce=@ud deadline=@ud =sig]
::  actions
::
+$  action
  $%  $:  %new-distributor
          staking-token=token-args
          reward-token-name=@t
          reward-token-symbol=@t
          reward-amount=@ud
          rewards-duration=@ud
          approve-staking-token=approval
          ::  do we need to approve the distributor to spend approve?
          ::  or will the user just approve the distributor to spend?
          approve-reward-token=approval
          ::  should we also add a bit of entropy here so that there
          ::  can be multiple distributors for the same token pair?
      ==  
  ::
      $:  %stake
          staking-token=token-args  
          approve-staking-token=approval
      ==
  ==
::
+$  action
  $%  $:  %start-pool
          token-a=token-args
          token-b=token-args
          approve-a=approval
          approve-b=approval
      ==
  ::
      $:  %swap
          pool-id=id
          payment=token-args
          receive=token-args
      ==
  ::
      $:  %add-liq
          pool-id=id
          token-a=token-args
          token-b=token-args
          approve-a=approval
          approve-b=approval
      ==
  ::
      $:  %remove-liq
          pool-id=id
          liq-shares-account=id
          amount=@ud
          token-a=[meta=id from-account=id]
          token-b=[meta=id from-account=id]
      ==
  ::
      $:  %on-push    ::  we only support %swap and %remove-liq
          from=id     ::  here, because these are the only two actions
          amount=@ud  ::  that only require ONE token approval.
          calldata=*
      ==
  ==
::
+$  sig  [v=@ r=@ s=@]
::  helpers
::
++  get-distributor-salt
  |=  [meta-a=id meta-b=id]
  ^-  @
  ?:  (gth meta-a meta-b)
    (cat 3 meta-a meta-b)
  (cat 3 meta-b meta-a)
--
::
++  get-pool-salt
  |=  [meta-a=id meta-b=id]
  ^-  @
  ?:  (gth meta-a meta-b)
    (cat 3 meta-a meta-b)
  (cat 3 meta-b meta-a)
--