import IcWebSocket, { generateRandomIdentity } from "ic-websocket-js";
import { canisterId, pingpong_backend } from "../../../declarations/pingpong_backend";

// Production
const gatewayUrl = "wss://gateway.icws.io";
const icUrl = "https://icp0.io";

// Local test
// const gatewayUrl = "ws://127.0.0.1:8080";
// const icUrl = "http://127.0.0.1:4943";


export const ws = new IcWebSocket(gatewayUrl, undefined, {
  canisterId: canisterId,
  canisterActor: pingpong_backend,
  identity: generateRandomIdentity(),
  networkUrl: icUrl,
});