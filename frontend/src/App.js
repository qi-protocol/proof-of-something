import { WagmiConfig, createConfig, configureChains, mainnet } from 'wagmi'
import { useAccount, useConnect, useDisconnect, useBalance } from 'wagmi'
import { useSignMessage } from 'wagmi'
import { recoverMessageAddress } from 'viem'
import { InjectedConnector } from 'wagmi/connectors/injected'
import { jsonRpcProvider } from 'wagmi/providers/jsonRpc';
import 'bootstrap/dist/css/bootstrap.min.css'; // import Bootstrap CSS
import { IDKitWidget } from '@worldcoin/idkit';
import { useIDKit } from '@worldcoin/idkit'
import { useEffect } from 'react';

import * as React from 'react'

import { usePrepareContractWrite, useContractWrite, useWaitForTransaction } from 'wagmi'


const { chains, publicClient } = configureChains(
  [mainnet],
  [
    jsonRpcProvider({
      rpc: () => ({
        http: 'https://still-orbital-theorem.base-goerli.quiknode.pro/7778efb6a98a8757645ed9ead407fd614d3964b9/'
      }),
    })
  ]
);

const config = createConfig({
  autoConnect: true,
  publicClient,
  connectors: [
    new InjectedConnector({
      chains,
      options: {
        name: 'Injected',
        shimDisconnect: true,
      },
    })
  ]
})

function Mint6551() {
  const { address } = useAccount();
  
  const { config } = usePrepareContractWrite({
    address: '0xFBA3912Ca04dd458c843e2EE08967fC04f3579c2',
    abi: [
      {
        name: 'mint',
        type: 'function',
        stateMutability: 'nonpayable',
        inputs: [],
        outputs: [],
      },
    ],
    functionName: 'mint',
  });
  
  const { data, write } = useContractWrite(config);
  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  });

  const handleMintSuccess = async () => {
    if (write) {
      await write();
    }
  };

  return (
    <div>
      <IDKitWidget
        app_id="app_staging_6b6a58cc303bea4e83f09d790b4f814d"
        action="create-6551"
        signal={address}
        onSuccess={handleMintSuccess}
        enableTelemetry
      >
        {({ open }) => (
          <button className="btn btn-primary mt-3" onClick={open} disabled={isLoading}>
            {isLoading ? 'Minting 6551 Wallet...' : 'MINT 6551'}
          </button>
        )}
      </IDKitWidget>

      {isSuccess && (
        <div>
          Successfully minted your NFT!
          <div>
            <a href={`https://etherscan.io/tx/${data?.hash}`}>Etherscan</a>
          </div>
        </div>
      )}
    </div>
  );
}

function Mint4337() {
  const { address } = useAccount();
  
  const { config } = usePrepareContractWrite({
    address: '0xFBA3912Ca04dd458c843e2EE08967fC04f3579c2',
    abi: [
      {
        name: 'mint',
        type: 'function',
        stateMutability: 'nonpayable',
        inputs: [],
        outputs: [],
      },
    ],
    functionName: 'mint',
  });
  
  const { data, write } = useContractWrite(config);
  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  });

  const handleMintSuccess = async () => {
    if (write) {
      await write();
    }
  };

  return (
    <div>
      <IDKitWidget
        app_id="app_staging_6b6a58cc303bea4e83f09d790b4f814d"
        action="create-6551"
        signal={address}
        onSuccess={handleMintSuccess}
        enableTelemetry
      >
        {({ open }) => (
          <button className="btn btn-primary mt-3" onClick={open} disabled={isLoading}>
            {isLoading ? 'Minting 6551 Wallet...' : 'MINT 437'}
          </button>
        )}
      </IDKitWidget>

      {isSuccess && (
        <div>
          Successfully minted your NFT!
          <div>
            <a href={`https://etherscan.io/tx/${data?.hash}`}>Etherscan</a>
          </div>
        </div>
      )}
    </div>
  );
}

function Transfer0() {
  const { config } = usePrepareContractWrite({
    address: '0xFBA3912Ca04dd458c843e2EE08967fC04f3579c2',
    abi: [
      {
        name: 'mint',
        type: 'function',
        stateMutability: 'nonpayable',
        inputs: [],
        outputs: [],
      },
    ],
    functionName: 'mint',
  })
  const { data, write } = useContractWrite(config)
 
  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  })
 
  return (
    <div>
      <button className="btn btn-primary mt-3" disabled={!write || isLoading} onClick={() => write()}>
        {isLoading ? 'Calling Transfer UserOp...' : 'CALL USEROP'}
      </button>
      {isSuccess && (
        <div>
          Successfully minted your NFT!
          <div>
            <a href={`https://etherscan.io/tx/${data?.hash}`}>Etherscan</a>
          </div>
        </div>
      )}
    </div>
  )
}


function Profile() {
  const { address } = useAccount()
  const { connect, isConnecting } = useConnect({
    connector: new InjectedConnector(),
  })
  const { disconnect } = useDisconnect()
  const { data, isError, isLoading } = useBalance({
    address: address,
  })

  if (address) {
    return (
      <div className="d-flex justify-content-center align-items-center vh-100">
        <div className="text-center">
          <p>Connected to {address}</p>
          <p>Balance: {data ? data.formatted : "Loading..."} ETH</p>
          <p>Chain ID: {config ? config.lastUsedChainId : ""}</p>
          <button className="btn btn-primary mt-3" onClick={disconnect}>Disconnect</button>
        </div>

        <Mint6551/>
        <Mint4337/>
        <Transfer0/>
      </div>
    )
  }

  if (isConnecting) {
    return (
      <div className="d-flex justify-content-center align-items-center vh-100">
        <p>Connecting...</p>
      </div>
    )
  }


  return (
    <div className="d-flex justify-content-center align-items-center vh-100">
      <button className="btn btn-primary" onClick={() => connect()}>Connect Wallet</button>
    </div>
  )
}

function App() {
  return (
    <>
    <WagmiConfig config={config}>
      <Profile/>
      
    </WagmiConfig>
  </>
  )
}

export default App;