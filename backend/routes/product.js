import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

let cart = [];
let wishlist = [];
let orders = [];

app.post("/cart/add", (req, res) => {
  const { productId, quantity } = req.body;
  cart.push({ productId, quantity });
  res.status(200).json({ message: "Added to cart", cart });
});

app.post("/order/create", (req, res) => {
  const { productId, quantity } = req.body;
  orders.push({ productId, quantity, date: new Date() });
  res.status(200).json({ message: "Order placed", orders });
});

app.post("/wishlist/toggle", (req, res) => {
  const { productId } = req.body;
  if (wishlist.includes(productId)) {
    wishlist = wishlist.filter((id) => id !== productId);
    return res.status(200).json({ message: "Removed from wishlist", wishlist });
  } else {
    wishlist.push(productId);
    return res.status(200).json({ message: "Added to wishlist", wishlist });
  }
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running at http://0.0.0.0:${PORT}`);
});
