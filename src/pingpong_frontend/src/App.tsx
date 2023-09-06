import React, { useState } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import PingPong from "./Components/PingPong";
import { ws } from "./utils/ws";
import Header from "./Components/Header";

const App = () => {

  return (
    <div className="bg-gray-900 text-gray-300">
    <Header />
    <PingPong/>
    </div>
  );
};

export default App;
