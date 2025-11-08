import 'package:greentalkies/colors.dart';
import 'package:greentalkies/models/product_model.dart';

final List<Product> allProducts = [
  // 🌱 Plants
  Product(id: '1', name: 'Fiddle Leaf Fig', description: 'Large indoor plant with lush leaves.', price: 120, imageUrl: 'assets/fiddle.jpg'),
  Product(id: '2', name: 'Snake Plant', description: 'Air-purifying easy-care plant.', price: 100, imageUrl: 'assets/snake_p.jpg'),
  Product(id: '3', name: 'Monstera Deliciosa', description: 'Tropical plant with unique leaves.', price: 150, imageUrl: 'assets/monstera.webp'),
  Product(id: '4', name: 'Aloe Vera', description: 'Medicinal succulent plant.', price: 60, imageUrl: 'assets/aleovera.jpg'),
  Product(id: '5', name: 'Succulent', description: 'Mini succulent.', price: 90, imageUrl: 'assets/succulent.jpg'),
  Product(id: '6', name: 'ZZ Plant', description: 'Hardy plant for low-light areas.', price: 89.99, imageUrl: 'assets/snake_p.jpg'),

  // 🪴 Pet-Friendly Plants
  Product(id: '7', name: 'Spider Plant', description: 'Safe for cats and dogs.', price: 399, imageUrl: 'assets/spider_plant.jpg'),
  Product(id: '8', name: 'Areca Palm', description: 'Non-toxic and purifies air.', price: 799, imageUrl: 'assets/areca_palm.webp'),
  Product(id: '9', name: 'Bamboo Palm', description: 'Pet-safe indoor palm.', price: 699, imageUrl: 'assets/bambo_palm.jpg'),
  Product(id: '10', name: 'Calathea', description: 'Colorful foliage, safe for pets.', price: 499, imageUrl: 'assets/calathea.webp'),
  Product(id: '11', name: 'Parlor Palm', description: 'Elegant indoor palm.', price: 599, imageUrl: 'assets/parlor_palm.webp'),

  // 🌬 Indoor Air Purifiers
  Product(id: '12', name: 'Snake Plant', description: 'Cleans indoor air.', price: 499, imageUrl: 'assets/snake_p.jpg'),
  Product(id: '13', name: 'Peace Lily', description: 'Removes indoor toxins.', price: 549, imageUrl: 'assets/peacelily.jpg'),
  Product(id: '14', name: 'Aloe Vera', description: 'Purifies air and medicinal plant.', price: 299, imageUrl: 'assets/aleovera.jpg'),
  Product(id: '15', name: 'Areca Palm', description: 'Moisturizes air naturally.', price: 799, imageUrl: 'assets/areca_palm.webp'),
  Product(id: '16', name: 'Rubber Plant', description: 'Removes indoor pollutants.', price: 699, imageUrl: 'assets/rubber_plant.jpg'),

  // 🏺 Terracotta Pots Sale
  Product(id: '17', name: 'Classic Terracotta Pot', description: 'Perfect for indoor plants.', price: 199, imageUrl: 'assets/classic_pot.jpg'),
  Product(id: '18', name: 'Terracotta Hanging Pot', description: 'Decorative and functional.', price: 299, imageUrl: 'assets/tera_hanging.jpg'),
  Product(id: '19', name: 'Mini Terracotta Set', description: 'Set of 3 small pots.', price: 249, imageUrl: 'assets/mini_tera.jpg'),
  Product(id: '20', name: 'Large Terracotta Pot', description: 'Ideal for bigger plants.', price: 399, imageUrl: 'assets/large_tera.jpg'),
  Product(id: '21', name: 'Terracotta Planter Bowl', description: 'Wide bowl planter.', price: 349, imageUrl: 'assets/planter_bowl.jpg'),
  Product(id: '22', name: 'Terracotta Pot', description: 'Simple decorative pot.', price: 40, imageUrl: 'assets/plastic_pots.jpg'),
  Product(id: '23', name: 'Ceramic Planter', description: 'Stylish planter pot.', price: 55, imageUrl: 'assets/ceramic_pot.webp'),
  Product(id: '24', name: 'Hanging Pot', description: 'Perfect for hanging plants.', price: 70, imageUrl: 'assets/hanging_pot.webp'),
  Product(id: '25', name: 'Square Pot', description: 'Modern square planter.', price: 45, imageUrl: 'assets/square_pot.jpg'),
  Product(id: '26', name: 'Mini Glass Pots Set', description: 'Set of 3 decorative glass pots.', price: 900, imageUrl: 'assets/painted_glass_pot.jpg'),

  // 🌿 Soils, Mixes & Fertilizers
  Product(id: '27', name: 'Monstera Potting Soil', description: 'Nutrient-rich soil for Monstera.', price: 58.50, imageUrl: 'assets/potting_soil_mix.webp'),
  Product(id: '28', name: 'Compost Mix', description: 'Organic mix for healthy soil.', price: 25, imageUrl: 'assets/compost_mix.webp'),
  Product(id: '29', name: 'Cactus Mix', description: 'Soil mix for cacti and succulents.', price: 28, imageUrl: 'assets/cactus_mix.webp'),
  Product(id: '30', name: 'Seedling Mix', description: 'Ideal for starting seeds.', price: 22, imageUrl: 'assets/seedlin_mix.jpg'),
  Product(id: '31', name: 'Organic Fertilizer', description: 'Boosts plant growth naturally.', price: 35, imageUrl: 'assets/organic_fertilizer.jpg'),
  Product(id: '32', name: 'BioGrow Compost', description: 'Enriched with beneficial microbes.', price: 249, imageUrl: 'assets/biogrow.webp'),
  Product(id: '33', name: 'Neem Cake', description: 'Natural pest repellent for all plants.', price: 199, imageUrl: 'assets/neem_cake.jpg'),
  Product(id: '34', name: 'VermiCompost Mix', description: 'Improves soil structure & fertility.', price: 299, imageUrl: 'assets/vermicompost.jpg'),
  Product(id: '35', name: 'Seaweed Extract', description: 'Boosts plant growth & root health.', price: 349, imageUrl: 'assets/seaweed_extract.png'),
  Product(id: '36', name: 'Bone Meal', description: 'Excellent source of phosphorus.', price: 179, imageUrl: 'assets/boneMeal.jpg'),
  Product(id: '37', name: 'Mustard Cake Powder', description: 'Promotes flowering & fruiting.', price: 159, imageUrl: 'assets/mustard_cake.jpg'),
  Product(id: '38', name: 'Organic NPK Blend', description: 'Balanced nutrients for all greens.', price: 379, imageUrl: 'assets/npk_blend.webp'),
  Product(id: '39', name: 'Coco Peat Fertilizer', description: 'Improves aeration & moisture retention.', price: 199, imageUrl: 'assets/coco_peat.jpg'),
  Product(id: '40', name: 'Fish Amino Acid', description: 'Natural nitrogen source for plants.', price: 269, imageUrl: 'assets/fish_amino_acid.jpg'),
  Product(id: '41', name: 'Compost Tea', description: 'Liquid fertilizer for instant results.', price: 229, imageUrl: 'assets/compost_tea.jpg'),

  // 🛠 Tools
  Product(id: '42', name: 'Garden Shovel', description: 'Durable shovel for gardening.', price: 50, imageUrl: 'assets/garden_sovles.jpg'),
  Product(id: '43', name: 'Pruning Shears', description: 'For precise trimming.', price: 40, imageUrl: 'assets/pruning_shears.jpg'),
  Product(id: '44', name: 'Watering Can', description: 'Easy watering for plants.', price: 35, imageUrl: 'assets/watering_can.jpg'),
  Product(id: '45', name: 'Garden Gloves', description: 'Protect your hands while gardening.', price: 20, imageUrl: 'assets/gardening_gloves.webp'),
  Product(id: '46', name: 'Mini Rake', description: 'Compact rake for small gardens.', price: 25, imageUrl: 'assets/mini_rake.jpg'),

  // 🌱 Misc
  Product(id: '47', name: 'AeroGarden Kit', description: 'Grow indoor herbs easily.', price: 300.00, imageUrl: 'assets/aerogarden.jpg'),
  Product(id: '48', name: 'Small Succulent Set', description: 'Mini succulent collection.', price: 90.00, imageUrl: 'assets/succulent.jpg'),
];
