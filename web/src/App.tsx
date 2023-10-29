import React from "react";
import { useEffect, useState } from "react";
import {
  BrowserRouter,
  Routes,
  Link,
  Router,
  Route,
  RouteProps,
} from "react-router-dom";
import { Layout, Row, Col, Button, Spin, List, Checkbox, Input } from "antd";
import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { CheckboxChangeEvent } from "antd/es/checkbox";
import { Provider, Network } from "aptos";
import "@aptos-labs/wallet-adapter-ant-design/dist/index.css";
import Admin from "./components/Admin";
import User from "./components/User";
import Navbar from "./components/Navbar";
import Register from "./components/Register";
import LandingPage from "./components/LandingPage";
import "./App.css";

type Task = {
  address: string;
  completed: boolean;
  content: string;
  task_id: string;
};

const App: React.FC = () => {
  const provider = new Provider(Network.DEVNET);
  const { account, signAndSubmitTransaction } = useWallet();
  const [accountHasList, setAccountHasList] = useState<boolean>(true);
  const [transactionInProgress, setTransactionInProgress] =
    useState<boolean>(false);
  const [isAdmin, setIsAdmin] = useState<boolean>(false);

  return (
    <>
      <BrowserRouter>
        <Navbar />
        <Routes>
          <Route path="/" Component={LandingPage} />
          <Route path="/admin" Component={Admin} />
          <Route path="/user" Component={User} />
          <Route path="/register" Component={Register} />
        </Routes>
      </BrowserRouter>

      {/* <User /> */}
    </>
  );
};

export default App;
