class PetProduct {
  final String name;
  final String price;
  final String imageUrl;
  final String description;

  const PetProduct({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

class PetProductsData {
  static List<PetProduct> getProducts() {
    return [
      PetProduct(
          name: "Premium Dog Food",
          price: "₹1,499",
          imageUrl: '../assets/images/dogfood.jpg',
          description: "High-quality nutrition for adult dogs"
      ),
      PetProduct(
          name: "Interactive Cat Toy",
          price: "₹799",
          imageUrl: 'assets/images/cattoy.jpg',
          description: "Keeps your cat entertained for hours"
      ),
      PetProduct(
          name: "Puppy Dental Chews",
          price: "₹499",
          imageUrl: 'assets/images/puppydentalchew.jpg',
          description: "Promotes dental health in young dogs"
      ),
      PetProduct(
          name: "Cat Scratching Post",
          price: "₹1,299",
          imageUrl: 'assets/images/catscratchingpost.jpg',
          description: "Durable sisal material with plush top"
      ),
      PetProduct(
          name: "Rabbit Hutch",
          price: "₹4,499",
          imageUrl: 'assets/images/rabbithutch.jpg',
          description: "Indoor/outdoor use with secure locks"
      ),
    ];
  }
}
