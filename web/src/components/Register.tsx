import React, { useState } from "react";

const Register: React.FC = () => {
  const [videoName, setVideoName] = useState<string>("");
  const [videoLength, setVideoLength] = useState<string>("");
  const [videoDescription, setVideoDescription] = useState<string>("");

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    // Handle form submission logic here, such as sending data to the server
    console.log("Video Name:", videoName);
    console.log("Video Length:", videoLength);
    console.log("Video Description:", videoDescription);
  };

  return (
    <div className="register-container">
      <h2>Register Video</h2>
      <form onSubmit={handleSubmit}>
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
  );
};

export default Register;
