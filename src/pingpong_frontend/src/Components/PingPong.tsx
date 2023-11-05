import React, { useEffect, useState } from "react";
import { BsArrowDown, BsArrowUp } from "react-icons/bs";
import { ws } from "../utils/ws";

type AppMessage = {
  message: string;
};

type uiMessage = {
  from: string;
  message: AppMessage;
};

const PingPong = () => {
  const [messages, setMessages] = useState<uiMessage[]>([]);
  const [messagesCount, setMessagesCount] = useState(0);
  const [isActive, setIsActive] = useState(false);

  const [connecting, setConnecting] = useState(true);
  const [isClosed, setIsClosed] = useState(false);
  const [isConnected, setIsConnected] = useState(false);

  ws.onopen = () => {
    console.log("Connected to the canister");
    setIsConnected(true);
    setIsClosed(false);
    setConnecting(false);
  };

  ws.onclose = () => {
    console.log("Disconnected from the canister");
    setIsClosed(true);
    setIsConnected(false);
    setConnecting(false);
  };

  ws.onerror = (error) => {
    console.log("Error:", error);
  };

  useEffect(() => {
    ws.onmessage = async (event) => {
      try {
        setIsActive(true);
        const recievedMessage: AppMessage = event.data;

        const fromBackendMessage: uiMessage = {
          from: "backend",
          message: recievedMessage,
        };
        setMessages((prev) => [...prev, fromBackendMessage]);

        setMessagesCount((prev) => prev + 1);

        setTimeout(async () => {
          sendMessage();
        }, 1000);
      } catch (error) {
        console.log("Error recievinf message", error);
      }
    };
  }, []);

  const sendMessage = async () => {
    try {
      const sentMessage: AppMessage = {
        message: "pong",
      };

      ws.send(sentMessage);
      const fromFrontendMessage: uiMessage = {
        from: "frontend",
        message: sentMessage,
      };
      setMessages((prev) => [...prev, fromFrontendMessage]);
    } catch (error) {
      console.log("Error on sending message", error);
    }
  };

  const handleClose = () => {
    ws.close();
  };

  const handleReconnect = () => {
    window.location.reload();
  };

  useEffect(() => {
    if (messagesCount === 25) {
      ws.close();
    }
  }, [messagesCount]);

  console.log(messages);
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <div className="min-h-screen min-w-[800px] mt-5 rounded bg-gray-700">
        <div className="w-full h-full flex gap-5 items-center justify-center my-5">
          {isConnected && (
            <h3 className="text-lg font-semibold">Websocket open</h3>
          )}
          {isClosed && (
            <h3 className="text-lg font-semibold">Websocket closed</h3>
          )}
          {connecting && (
            <h3 className="text-lg font-semibold">Websocket connecting</h3>
          )}

          {!isActive && !connecting ? (
            <button
              onClick={handleReconnect}
              className={` ${
                connecting ? `hidden` : `block`
              } bg-blue-500 rounded-lg py-1.5 px-2 font-semibold hover:bg-gray-900`}
            >
              Replay
            </button>
          ) : (
            <button
              onClick={isConnected ? handleClose : handleReconnect}
              className={` ${
                connecting ? `hidden` : `block`
              } bg-blue-500 rounded-lg py-1.5 px-2 font-semibold hover:bg-gray-900`}
            >
              {isConnected ? "Close" : "Reconnect"}
            </button>
          )}
        </div>
        <div className="mt-5">
          {messages.map((message, index) => (
            <div
              key={index}
              className={` ${
                message.from === "backend"
                  ? `bg-gray-900  text-gray-200`
                  : `bg-gray-200 text-gray-950`
              }  mx-5  p-2 flex gap-10`}
            >
              {message.from === "backend" ? (
                <span className="flex gap-3 items-center">
                  <BsArrowDown /> <h1>Backend</h1>
                </span>
              ) : (
                <span className="flex gap-3 items-center">
                  <BsArrowUp /> <h1>Frontend</h1>
                </span>
              )}
              {message.from === "backend" ? <h1>Pong</h1> : <h1>Ping</h1>}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default PingPong;
