import express from "express";
import cors from "cors";
import authRoute from "./route/route-api";

const app = express();

app.use(cors());
app.use(express.json());

app.use("/auth", authRoute);

app.listen(3000, () => {
  console.log("Server jalan di 3000");
});
