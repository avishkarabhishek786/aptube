import React from "react";

const Admin = () => {
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
    </>
  );
};

export default Admin;
