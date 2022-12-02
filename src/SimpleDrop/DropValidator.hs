{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeApplications      #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE TypeOperators         #-}

{-# OPTIONS_GHC -fno-warn-unused-imports #-}

module SimpleDrop.DropValidator where

import qualified PlutusTx
import           PlutusTx.Prelude     hiding (Semigroup(..), unless)
import           Ledger               hiding (singleton)
import qualified Ledger.Typed.Scripts as Scripts
import           Prelude              (Show)
import qualified Plutus.Script.Utils.V1.Typed.Scripts as TScripts
import qualified Plutus.V1.Ledger.Scripts as Plutus

type ListOfDelegators = [PaymentPubKeyHash]
data DropParam = DropParam { delegators :: ListOfDelegators } 
      deriving Show

PlutusTx.makeLift ''DropParam

{-# INLINABLE mkValidator #-}
mkValidator :: DropParam -> () -> () -> ScriptContext -> Bool
mkValidator p () () ctx = traceIfFalse "signatory not in Whitelist" isSignedByWLDelegator
  where
    _transaction :: TxInfo
    _transaction = scriptContextTxInfo ctx

    _listOfPubKeyHash :: [PubKeyHash]
    _listOfPubKeyHash = PlutusTx.Prelude.map (unPaymentPubKeyHash) (delegators p)

    -- Checks whether signatory of this transaction
    -- is included on the WhiteList hardcoded in the Datum
    isSignedByWLDelegator :: Bool
    isSignedByWLDelegator = any (txSignedBy _transaction) $ _listOfPubKeyHash

data Droping
instance Scripts.ValidatorTypes Droping where
    type instance DatumType Droping = ()
    type instance RedeemerType Droping = ()

typedValidator :: DropParam -> Scripts.TypedValidator Droping
typedValidator p = Scripts.mkTypedValidator @Droping
    ($$(PlutusTx.compile [|| mkValidator ||]) `PlutusTx.applyCode` PlutusTx.liftCode p)
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = TScripts.mkUntypedValidator @() @()

validator :: DropParam -> Plutus.Validator
validator = Scripts.validatorScript . typedValidator

valHash :: DropParam -> Plutus.ValidatorHash
valHash = Scripts.validatorHash . typedValidator

scrAddress :: DropParam -> Ledger.Address
scrAddress = scriptAddress . validator
