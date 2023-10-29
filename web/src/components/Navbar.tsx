import React from "react";
import { useState } from "react";
import { Link } from "react-router-dom";
import { Layout, Row, Col, Button, Spin, List, Checkbox, Input } from "antd";
import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design";
import "@aptos-labs/wallet-adapter-ant-design/dist/index.css";
import "../App.css";

type Task = {
  address: string;
  completed: boolean;
  content: string;
  task_id: string;
};

const Navbar: React.FC = () => {
  const [isAdmin, setIsAdmin] = useState<boolean>(false);

  return (
    <>
      <Layout>
        <Row align="middle">
          <Col span={10} offset={2}>
          <Link to="/"><h1>APTube</h1></Link>
          </Col>

          <Col span={150} style={{ textAlign: "right", paddingRight: "200px" }}>
            <WalletSelector />
          </Col>
          <Link to="/admin" className="button">Admin</Link>
          <Link to="/user" className="button">User</Link>
          <Link to="/register" className="button">Register</Link>
        </Row> 
      </Layout>
    </>
  );
};

export default Navbar;
