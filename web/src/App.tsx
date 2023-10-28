import React from "react";
import { useEffect, useState } from "react";
import {
  BrowserRouter,
  Routes,
  Link,
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
  const [accountHasList, setAccountHasList] = useState<boolean>(false);
  const [transactionInProgress, setTransactionInProgress] =
    useState<boolean>(false);

  return (
    <>
      <Layout>
        <Row align="middle">
          <Col span={10} offset={2}>
            <h1>APTube</h1>
          </Col>

          <Col span={12} style={{ textAlign: "center", paddingRight: "200px" }}>
            <WalletSelector />
          </Col>
          <Col span={120} style={{ textAlign: "right", paddingRight: "20px" }}>
            <BrowserRouter>
              <Link to="/admin">
                <button className="button">Admin</button>
              </Link>
              <Routes>
                <Route path="/admin" element={<Admin />} />
              </Routes>
            </BrowserRouter>
          </Col>
        </Row>
      </Layout>

      <User />
    </>
  );
};

export default App;
