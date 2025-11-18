import express from "express";
import cors from "cors";

const app = express();
app.use(cors());

// Página simple ADMIN
app.get("/admin", (req, res) => {
  res.send("<h1 style='text-align:center;margin-top:50px;'>ADMIN</h1>");
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Backend corriendo en puerto ${PORT}`));
