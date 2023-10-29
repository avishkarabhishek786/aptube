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
import Admin from "./Admin";
import "../App.css";

type Task = {
  address: string;
  completed: boolean;
  content: string;
  task_id: string;
};

const User: React.FC = () => {
  const provider = new Provider(Network.DEVNET);
  const { account, signAndSubmitTransaction } = useWallet();
  const [accountHasList, setAccountHasList] = useState<boolean>(false);
  const [transactionInProgress, setTransactionInProgress] =
    useState<boolean>(false);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [newTask, setNewTask] = useState<string>("");

  const moduleAddress =
    "0x3310257dfaeebbf0d3b842a4a7e693ebc0264266ceb900972b72cbae7eac219c";

  useEffect(() => {
    fetchList();
  }, [account?.address]);

  // const onWriteTask = (event: React.ChangeEvent<HTMLInputElement>) => {
  //   const value = event.target.value;
  //   setNewTask(value);
  // };

  const fetchList = async () => {
    if (!account) return [];
    try {
      const TodoListResource = await provider.getAccountResource(
        account?.address,
        `${moduleAddress}::todolist::TodoList`
      );
      setAccountHasList(true);
      // tasks table handle
      const tableHandle = (TodoListResource as any).data.tasks.handle;
      // tasks table counter
      const taskCounter = (TodoListResource as any).data.task_counter;

      let tasks: any = [];
      let counter = 1;
      while (counter <= taskCounter) {
        const tableItem = {
          key_type: "u64",
          value_type: `${moduleAddress}::todolist::Task`,
          key: `${counter}`,
        };
        const task = await provider.getTableItem(tableHandle, tableItem);
        tasks.push(task);
        counter++;
      }
      // set tasks in local state
      setTasks(tasks);
    } catch (e: any) {
      setAccountHasList(false);
    }
  };

  // const addNewList = async () => {
  //   if (!account) return [];
  //   setTransactionInProgress(true);
  //   // build a transaction payload to be submited
  //   const payload = {
  //     type: "entry_function_payload",
  //     function: `${moduleAddress}::todolist::create_list`,
  //     type_arguments: [],
  //     arguments: [],
  //   };
  //   try {
  //     // sign and submit transaction to chain
  //     const response = await signAndSubmitTransaction(payload);
  //     // wait for transaction
  //     await provider.waitForTransaction(response.hash);
  //     setAccountHasList(true);
  //   } catch (error: any) {
  //     setAccountHasList(false);
  //   }
  // };
  // const onTaskAdded = async () => {
  //   // check for connected account
  //   if (!account) return;
  //   setTransactionInProgress(true);
  //   // build a transaction payload to be submited
  //   const payload = {
  //     type: "entry_function_payload",
  //     function: `${moduleAddress}::todolist::create_task`,
  //     type_arguments: [],
  //     arguments: [newTask],
  //   };

  //   // hold the latest task.task_id from our local state
  //   const latestId =
  //     tasks.length > 0 ? parseInt(tasks[tasks.length - 1].task_id) + 1 : 1;

  //   // build a newTaskToPush object into our local state
  //   const newTaskToPush = {
  //     address: account.address,
  //     completed: false,
  //     content: newTask,
  //     task_id: latestId + "",
  //   };

  //   try {
  //     // sign and submit transaction to chain
  //     const response = await signAndSubmitTransaction(payload);
  //     // wait for transaction
  //     await provider.waitForTransaction(response.hash);

  //     // Create a new array based on current state:
  //     let newTasks = [...tasks];

  //     // Add item to the tasks array
  //     newTasks.push(newTaskToPush);
  //     // Set state
  //     setTasks(newTasks);
  //     // clear input text
  //     setNewTask("");
  //   } catch (error: any) {
  //     console.log("error", error);
  //   } finally {
  //     setTransactionInProgress(false);
  //   }
  // };

  // const onCheckboxChange = async (
  //   event: CheckboxChangeEvent,
  //   taskId: string
  // ) => {
  //   if (!account) return;
  //   if (!event.target.checked) return;
  //   setTransactionInProgress(true);
  //   const payload = {
  //     type: "entry_function_payload",
  //     function: `${moduleAddress}::todolist::complete_task`,
  //     type_arguments: [],
  //     arguments: [taskId],
  //   };

  //   try {
  //     // sign and submit transaction to chain
  //     const response = await signAndSubmitTransaction(payload);
  //     // wait for transaction
  //     await provider.waitForTransaction(response.hash);

  //     setTasks((prevState) => {
  //       const newState = prevState.map((obj) => {
  //         // if task_id equals the checked taskId, update completed property
  //         if (obj.task_id === taskId) {
  //           return { ...obj, completed: true };
  //         }

  //         // otherwise return object as is
  //         return obj;
  //       });

  //       return newState;
  //     });
  //   } catch (error: any) {
  //     console.log("error", error);
  //   } finally {
  //     setTransactionInProgress(false);
  //   }
  // };

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
          </div>
        ))}
      </div>
      {/* <Spin spinning={transactionInProgress}>
        {!accountHasList ? (
          <Row gutter={[0, 32]} style={{ marginTop: "2rem" }}>
            <Col span={8} offset={8}>
              <Button
                disabled={!account}
                block
                onClick={addNewList}
                type="primary"
                style={{ height: "40px", backgroundColor: "#3f67ff" }}
              >
                Add new list
              </Button>
            </Col>
          </Row>
        ) : (
          <Row gutter={[0, 32]} style={{ marginTop: "2rem" }}>
            <Col span={8} offset={8}>
              <Input.Group compact>
                <Input
                  onChange={(event) => onWriteTask(event)}
                  style={{ width: "calc(100% - 60px)" }}
                  placeholder="Add a Task"
                  size="large"
                  value={newTask}
                />
                <Button
                  onClick={onTaskAdded}
                  type="primary"
                  style={{ height: "40px", backgroundColor: "#3f67ff" }}
                >
                  Add
                </Button>
              </Input.Group>
            </Col>
            <Col span={8} offset={8}>
              {tasks && (
                <List
                  size="small"
                  bordered
                  dataSource={tasks}
                  renderItem={(task: any) => (
                    <List.Item
                      actions={[
                        <div>
                          {task.completed ? (
                            <Checkbox defaultChecked={true} disabled />
                          ) : (
                            <Checkbox
                              onChange={(event) =>
                                onCheckboxChange(event, task.task_id)
                              }
                            />
                          )}
                        </div>,
                      ]}
                    >
                      <List.Item.Meta
                        title={task.content}
                        description={
                          <a
                            href={`https://explorer.aptoslabs.com/account/${task.address}/`}
                            target="_blank"
                          >{`${task.address.slice(0, 6)}...${task.address.slice(
                            -5
                          )}`}</a>
                        }
                      />
                    </List.Item>
                  )}
                />
              )}
            </Col>
          </Row>
        )}
      </Spin> */}
    </>
  );
};

export default User;
