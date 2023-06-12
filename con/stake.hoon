/+  *zig-sys-smart
/=  lib  /con/lib/amm
|_  =context
++  write
  |=  act=action:lib
  ^-  (quip call diff)
  ?-    -.act
      %new-distributor
    =,  act
    ::  determine unique salt for new distributor
    ::  if we do it this way will we also need to collect
    ::  some entropy from the ship? otherwise there could only
    ::  be one distributor for staked/reward token pair
    =/  distributor-salt=@  (get-distributor-salt:lib meta.staking-token reward-token-name)
    ::  is the following good for reward-token-salt?
    =/  reward-token-salt=@  (get-reward-token-salt:lib meta.staking-token reward-token-name)
    ::
    ::  find contract ID for staking token
    =/  staking-token-scry  (need (scry-state meta.staking-token))
    ?>  ?=(%& -.staking-token-scry)
    =/  contract-staking-token=id  source.p.staking-token-scry
    ::
    =/  reward-token-meta-id
      %-  hash-data
      :^    our-fungible-contract:lib
          our-fungible-contract:lib
        town.context
      ::  fungible contract appends caller ID (our ID) to salt
      (cat 3 reward-token-salt this.context)
    ::  create new distributor
    =/  distributor-id=id  (hash-data this.context this.context town.context distributor-salt)
    ::  this assumes we will mint the reward token in the amount required for first period
    =/  =distributor:lib
      :*  [meta.staking-token contract-staking-token 0]  ::  last argument is init to 0 right?
          [meta.reward-token contract-reward-token reward-amount]  ::  how to we get the reward contract address?
          0  ::  init period-finish to 0
          (div reward-amount rewards-duration)  ::  how to handle this math?
          rewards-duration
          0  ::  init last-update-time to 0
          0  ::  init reward-per-token-stored to 0
          ~  ::  will ~ init a blank pmap?
          ~  ::  will ~ init a blank pmap?
          0  ::  init total-supply of of staking-token to 0
          ~  ::  will ~ init a blank pmap?
          reward-amount  ::  init distributor-reward-amount to reward-amount for first period
      ==
    =/  =data  [distributor-id this.context this.context town.context distributor-salt %distributor distributor]
    ::
    :_  (result ~ [%& data]~ ~ ~)
    :~  our-fungible-contract:lib
      town.context
    :*  %deploy
        :((cury cat 3) reward-token-name)
        :((cury cat 3) reward-token-symbol)
        reward-token-salt
        ~
        minters=[this.context ~ ~]
        [[distributor-address amount] ~]  ::  how do we get the address of the yet to be deployed distributor?
    ==            
  ::
  ==
==
++  read
  |=  =pith
  ~
--
