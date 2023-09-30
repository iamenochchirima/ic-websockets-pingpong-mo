import IcWebSocket, { generateRandomIdentity } from "ic-websocket-js";

// Production
const gatewayUrl = "wss://gatewayv1.icws.io";
const icUrl = "https://icp0.io";
const canisterId = "kio63-vyaaa-aaaal-qcd6q-cai";

// Local test
// const gatewayUrl = "ws://127.0.0.1:8080";
// const icUrl = "http://127.0.0.1:4943";
// const canisterId = "bkyz2-fmaaa-aaaaa-qaaaq-cai";


export const ws = new IcWebSocket(gatewayUrl, undefined, {
  canisterId: canisterId,
  networkUrl: icUrl,
  identity: generateRandomIdentity(),
});