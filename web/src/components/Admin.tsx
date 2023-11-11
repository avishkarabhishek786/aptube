import React, { useEffect, useState } from "react";
import { Provider, Network } from "aptos";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { moduleAddress } from "../constants/constant";

const provider = new Provider(Network.DEVNET);

const Admin = () => {
  const [accountHasList, setAccountHasList] = useState<boolean>(false);
  const { account } = useWallet();

  useEffect(() => {
    fetchList();
  }, [account?.address]);

  const fetchList = async () => {
    if (!account) return [];
    // change this to be your module account address
    try {
      const TodoListResource = await provider.getAccountResource(
        account.address,
        `${moduleAddress}::Invest::ListedProject`
      );
      setAccountHasList(true);
    } catch (e: any) {
      setAccountHasList(false);
    }
  };

  const videos = [
    {
      id: 1,
      title: "Video 1",
      url: "https://www.youtube.com/embed/video1",
    },
    {
      id: 2,
      title: "Video 2",
      url: "https://www.youtube.com/embed/video2",
    },
    {
      id: 3,
      title: "Video 3",
      url: "https://www.youtube.com/embed/video3",
    },
    {
      id: 4,
      title: "Video 4",
      url: "https://www.youtube.com/embed/video4",
    },
    {
      id: 5,
      title: "Video 5",
      url: "https://www.youtube.com/embed/video5",
    },
    {
      id: 6,
      title: "Video 6",
      url: "https://www.youtube.com/embed/video6",
    },
    // Add more video objects as needed
  ];
  return (
    <>
      {accountHasList ? (
        <div className="video-list">
          {videos.map((video) => (
            <div key={video.id} className="video-thumbnail">
              <h2>{video.title}</h2>
              <iframe
                title={video.title}
                width="560"
                height="315"
                src={video.url}
                frameBorder="0"
                allowFullScreen
              ></iframe>
              <button className="button">Approve</button>
              <button className="button">Reject</button>
            </div>
          ))}
        </div>
      ) : (
        <h3>"No videos uploaded Yet"</h3>
      )}
    </>
  );
};

export default Admin;
