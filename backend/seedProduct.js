import mongoose from "mongoose";
import dotenv from "dotenv";
import Product from "./models/Product.js";

dotenv.config({ path: "./details.env" });

// --------------------
// MongoDB Connection
// --------------------
const uri = `mongodb+srv://${process.env.DB_USER}:${encodeURIComponent(
  process.env.DB_PASS
)}@cluster0.kqyyfl6.mongodb.net/${process.env.DB_NAME}?retryWrites=true&w=majority`;

mongoose
  .connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log("✅ MongoDB Connected"))
  .catch((err) => console.log("❌ MongoDB Error:", err.message));

// --------------------
// Hardcoded Products
// --------------------
const products = [
  { name: 'Fiddle Leaf Fig', description: 'Large indoor plant with lush leaves.', price: 120, imageUrl: 'assets/fiddle.jpg' },
  { name: 'Snake Plant', description: 'Air-purifying easy-care plant.', price: 100, imageUrl: 'assets/snake_p.jpg' },
  { name: 'Monstera Deliciosa', description: 'Tropical plant with unique leaves.', price: 150, imageUrl: 'assets/monstera.webp' },
  { name: 'Aloe Vera', description: 'Medicinal succulent plant.', price: 60, imageUrl: 'assets/aleovera.jpg' },
  { name: 'Succulent', description: 'Mini succulent.', price: 90, imageUrl: 'assets/succulent.jpg' },
  { name: 'ZZ Plant', description: 'Hardy plant for low-light areas.', price: 89.99, imageUrl: 'assets/snake_p.jpg' },
  { name: 'Spider Plant', description: 'Safe for cats and dogs.', price: 399, imageUrl: 'assets/spider_plant.jpg' },
  { name: 'Areca Palm', description: 'Non-toxic and purifies air.', price: 799, imageUrl: 'assets/areca_palm.webp' },
  { name: 'Bamboo Palm', description: 'Pet-safe indoor palm.', price: 699, imageUrl: 'assets/bambo_palm.jpg' },
  { name: 'Calathea', description: 'Colorful foliage, safe for pets.', price: 499, imageUrl: 'assets/calathea.webp' },
  { name: 'Parlor Palm', description: 'Elegant indoor palm.', price: 599, imageUrl: 'assets/parlor_palm.webp' },
  { name: 'Snake Plant', description: 'Cleans indoor air.', price: 499, imageUrl: 'assets/snake_p.jpg' },
  { name: 'Peace Lily', description: 'Removes indoor toxins.', price: 549, imageUrl: 'assets/peacelily.jpg' },
  { name: 'Aloe Vera', description: 'Purifies air and medicinal plant.', price: 299, imageUrl: 'assets/aleovera.jpg' },
  { name: 'Areca Palm', description: 'Moisturizes air naturally.', price: 799, imageUrl: 'assets/areca_palm.webp' },
  { name: 'Rubber Plant', description: 'Removes indoor pollutants.', price: 699, imageUrl: 'assets/rubber_plant.jpg' },
  { name: 'Classic Terracotta Pot', description: 'Perfect for indoor plants.', price: 199, imageUrl: 'assets/classic_pot.jpg' },
  { name: 'Terracotta Hanging Pot', description: 'Decorative and functional.', price: 299, imageUrl: 'assets/tera_hanging.jpg' },
  { name: 'Mini Terracotta Set', description: 'Set of 3 small pots.', price: 249, imageUrl: 'assets/mini_tera.jpg' },
  { name: 'Large Terracotta Pot', description: 'Ideal for bigger plants.', price: 399, imageUrl: 'assets/large_tera.jpg' },
  { name: 'Terracotta Planter Bowl', description: 'Wide bowl planter.', price: 349, imageUrl: 'assets/planter_bowl.jpg' },
  { name: 'Terracotta Pot', description: 'Simple decorative pot.', price: 40, imageUrl: 'assets/plastic_pots.jpg' },
  { name: 'Ceramic Planter', description: 'Stylish planter pot.', price: 55, imageUrl: 'assets/ceramic_pot.webp' },
  { name: 'Hanging Pot', description: 'Perfect for hanging plants.', price: 70, imageUrl: 'assets/hanging_pot.webp' },
  { name: 'Square Pot', description: 'Modern square planter.', price: 45, imageUrl: 'assets/square_pot.jpg' },
  { name: 'Mini Glass Pots Set', description: 'Set of 3 decorative glass pots.', price: 900, imageUrl: 'assets/painted_glass_pot.jpg' },
  { name: 'Monstera Potting Soil', description: 'Nutrient-rich soil for Monstera.', price: 58.50, imageUrl: 'assets/potting_soil_mix.webp' },
  { name: 'Compost Mix', description: 'Organic mix for healthy soil.', price: 25, imageUrl: 'assets/compost_mix.webp' },
  { name: 'Cactus Mix', description: 'Soil mix for cacti and succulents.', price: 28, imageUrl: 'assets/cactus_mix.webp' },
  { name: 'Seedling Mix', description: 'Ideal for starting seeds.', price: 22, imageUrl: 'assets/seedlin_mix.jpg' },
  { name: 'Organic Fertilizer', description: 'Boosts plant growth naturally.', price: 35, imageUrl: 'assets/organic_fertilizer.jpg' },
  { name: 'BioGrow Compost', description: 'Enriched with beneficial microbes.', price: 249, imageUrl: 'assets/biogrow.webp' },
  { name: 'Neem Cake', description: 'Natural pest repellent for all plants.', price: 199, imageUrl: 'assets/neem_cake.jpg' },
  { name: 'VermiCompost Mix', description: 'Improves soil structure & fertility.', price: 299, imageUrl: 'assets/vermicompost.jpg' },
  { name: 'Seaweed Extract', description: 'Boosts plant growth & root health.', price: 349, imageUrl: 'assets/seaweed_extract.png' },
  { name: 'Bone Meal', description: 'Excellent source of phosphorus.', price: 179, imageUrl: 'assets/boneMeal.jpg' },
  { name: 'Mustard Cake Powder', description: 'Promotes flowering & fruiting.', price: 159, imageUrl: 'assets/mustard_cake.jpg' },
  { name: 'Organic NPK Blend', description: 'Balanced nutrients for all greens.', price: 379, imageUrl: 'assets/npk_blend.webp' },
  { name: 'Coco Peat Fertilizer', description: 'Improves aeration & moisture retention.', price: 199, imageUrl: 'assets/coco_peat.jpg' },
  { name: 'Fish Amino Acid', description: 'Natural nitrogen source for plants.', price: 269, imageUrl: 'assets/fish_amino_acid.jpg' },
  { name: 'Compost Tea', description: 'Liquid fertilizer for instant results.', price: 229, imageUrl: 'assets/compost_tea.jpg' },
  { name: 'Garden Shovel', description: 'Durable shovel for gardening.', price: 50, imageUrl: 'assets/garden_sovles.jpg' },
  { name: 'Pruning Shears', description: 'For precise trimming.', price: 40, imageUrl: 'assets/pruning_shears.jpg' },
  { name: 'Watering Can', description: 'Easy watering for plants.', price: 35, imageUrl: 'assets/watering_can.jpg' },
  { name: 'Garden Gloves', description: 'Protect your hands while gardening.', price: 20, imageUrl: 'assets/gardening_gloves.webp' },
  { name: 'Mini Rake', description: 'Compact rake for small gardens.', price: 25, imageUrl: 'assets/mini_rake.jpg' },
  { name: 'AeroGarden Kit', description: 'Grow indoor herbs easily.', price: 300, imageUrl: 'assets/aerogarden.jpg' },
  { name: 'Small Succulent Set', description: 'Mini succulent collection.', price: 90, imageUrl: 'assets/succulent.jpg' },
];

// --------------------
// Seed Function
// --------------------
const seedProducts = async () => {
  try {
    await Product.deleteMany({}); // Optional: clear existing products
    await Product.insertMany(products);
    console.log("✅ All products added successfully!");
    mongoose.connection.close();
  } catch (err) {
    console.error("❌ Error seeding products:", err.message);
    mongoose.connection.close();
  }
};

seedProducts();
