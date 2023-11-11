import React, { useState } from "react";
import { Provider, Network } from "aptos";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Spin } from "antd";
import { moduleAddress } from "../constants/constant";

export const provider = new Provider(Network.DEVNET);

const Register: React.FC = () => {
  const [videoName, setVideoName] = useState<string>("");
  const [videoLength, setVideoLength] = useState<string>("");
  const [videoDescription, setVideoDescription] = useState<string>("");
  const [accountHasProject, setaccountHasProject] = useState<boolean>(false);
  const [transactionInProgress, setTransactionInProgress] =
    useState<boolean>(false);

  const { account, signAndSubmitTransaction } = useWallet();

  const addNewProject = async (event: React.FormEvent) => {
    event.preventDefault();
    // Handle form submission logic here, such as sending data to the server
    if (!account) return [];
    setTransactionInProgress(true);
    // build a transaction payload to be submited
    const payload = {
      type: "entry_function_payload",
      function: `${moduleAddress}::Invest::list_project`,
      type_arguments: [],
      arguments: [],
    };
    try {
      // sign and submit transaction to chain
      const response = await signAndSubmitTransaction(payload);
      // wait for transaction
      await provider.waitForTransaction(response.hash);
      setaccountHasProject(true);
    } catch (error: any) {
      setaccountHasProject(false);
    } finally {
      setTransactionInProgress(false);
    }
  };

  return (
    <>
      <Spin spinning={transactionInProgress}>
        <div className="register-container">
          <h2>Register Video</h2>
          <form onSubmit={addNewProject}>
            <div className="form-group">
              <label>Video Name:</label>
              <input
                type="text"
                value={videoName}
                onChange={(e) => setVideoName(e.target.value)}
                required
              />
            </div>
            <div className="form-group">
              <label>Video Length:</label>
              <input
                type="text"
                value={videoLength}
                onChange={(e) => setVideoLength(e.target.value)}
                required
              />
            </div>
            <div className="form-group">
              <label>Video Description:</label>
              <textarea
                value={videoDescription}
                onChange={(e) => setVideoDescription(e.target.value)}
                required
              />
            </div>
            <button className="button" type="submit">
              Submit
            </button>
          </form>
        </div>
      </Spin>
    </>
  );
};

export default Register;
