import 'package:flutter/material.dart';

class Pet {
  final String id;
  final String name;
  final String type;
  final String breed;
  final int age;
  final String gender;
  final String imageUrl;
  final String description;
  final bool isAdopted;
  final Map<String, double> personalityTraits;
  final List<MedicalRecord> medicalHistory;
  final String dietaryNeeds;
  final HealthStatus healthStatus;
  final int totalUsers;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.gender,
    required this.imageUrl,
    required this.description,
    this.isAdopted = false,
    this.personalityTraits = const {},
    this.medicalHistory = const [],
    this.dietaryNeeds = '',
    this.healthStatus = const HealthStatus(),
    this.totalUsers = 0,
  });
}

class MedicalRecord {
  final String date;
  final String description;
  final String details;

  const MedicalRecord({
    required this.date,
    required this.description,
    required this.details,
  });
}

class HealthStatus {
  final bool isVaccinated;
  final bool isNeutered;
  final bool isMicrochipped;

  const HealthStatus({
    this.isVaccinated = false,
    this.isNeutered = false,
    this.isMicrochipped = false,
  });
}

class PetService {
  // Singleton pattern
  static final PetService _instance = PetService._internal();
  factory PetService() => _instance;
  PetService._internal();

  final List<Pet> _pets = [
    Pet(
      id: '1',
      name: 'Buddy',
      type: 'Dog',
      breed: 'Golden Retriever',
      age: 3,
      gender: 'Male',
      imageUrl: 'assets/images/buddy.jpg',
      description: 'Friendly and energetic Golden Retriever who loves to play fetch.',
      personalityTraits: {
        'Friendly': 0.9,
        'Playful': 0.8,
        'Energetic': 0.7,
        'Trainable': 0.9,
        'Good with kids': 0.9,
      },
      medicalHistory: [
        MedicalRecord(
          date: '03/15/2025',
          description: 'General checkup',
          details: 'All clear, healthy and active',
        ),
        MedicalRecord(
          date: '01/10/2025',
          description: 'Vaccinations',
          details: 'DHPP, Rabies, Bordetella',
        ),
      ],
      dietaryNeeds: 'Buddy is currently on a diet of premium dog food, twice daily. He has no known food allergies and maintains a healthy weight.',
      healthStatus: HealthStatus(
        isVaccinated: true,
        isNeutered: true,
        isMicrochipped: false,
      ),
      totalUsers: 2854,
    ),
    Pet(
      id: '2',
      name: 'Max',
      type: 'Dog',
      breed: 'German Shepherd',
      age: 2,
      gender: 'Male',
      imageUrl: 'assets/images/max.jpg',
      description: 'Intelligent and loyal German Shepherd, great with kids.',
      personalityTraits: {
        'Friendly': 0.7,
        'Playful': 0.6,
        'Energetic': 0.8,
        'Trainable': 0.9,
        'Good with kids': 0.8,
      },
      medicalHistory: [
        MedicalRecord(
          date: '02/20/2025',
          description: 'General checkup',
          details: 'Healthy and active',
        ),
        MedicalRecord(
          date: '12/15/2024',
          description: 'Vaccinations',
          details: 'DHPP, Rabies',
        ),
      ],
      dietaryNeeds: 'Max is currently on a diet of premium dog food, twice daily. He has no known food allergies and maintains a healthy weight.',
      healthStatus: HealthStatus(
        isVaccinated: true,
        isNeutered: true,
        isMicrochipped: true,
      ),
      totalUsers: 2960,
    ),
    Pet(
      id: '3',
      name: 'Bella',
      type: 'Cat',
      breed: 'Siamese',
      age: 1,
      gender: 'Female',
      imageUrl: 'assets/images/bella.jpg',
      description: 'Elegant Siamese cat who loves to cuddle and play.',
      personalityTraits: {
        'Friendly': 0.6,
        'Playful': 0.9,
        'Energetic': 0.7,
        'Trainable': 0.5,
        'Good with kids': 0.7,
      },
      medicalHistory: [
        MedicalRecord(
          date: '03/01/2025',
          description: 'General checkup',
          details: 'Healthy and active',
        ),
        MedicalRecord(
          date: '12/05/2024',
          description: 'Spaying',
          details: 'Successful procedure, complete recovery',
        ),
      ],
      dietaryNeeds: 'Bella is currently on a diet of premium cat food, twice daily. She has no known food allergies and maintains a healthy weight.',
      healthStatus: HealthStatus(
        isVaccinated: true,
        isNeutered: true,
        isMicrochipped: false,
      ),
      totalUsers: 1854,
    ),
    Pet(
      id: '4',
      name: 'Charlie',
      type: 'Dog',
      breed: 'Beagle',
      age: 4,
      gender: 'Male',
      imageUrl: 'assets/images/charlie.jpg',
      description: 'Curious and friendly Beagle with a great sense of smell.',
      personalityTraits: {
        'Friendly': 0.9,
        'Playful': 0.7,
        'Energetic': 0.8,
        'Trainable': 0.6,
        'Good with kids': 0.9,
      },
      medicalHistory: [
        MedicalRecord(
          date: '02/10/2025',
          description: 'General checkup',
          details: 'Healthy and active',
        ),
      ],
      dietaryNeeds: 'Charlie is currently on a diet of premium dog food, twice daily. He has no known food allergies and maintains a healthy weight.',
      healthStatus: HealthStatus(
        isVaccinated: true,
        isNeutered: true,
        isMicrochipped: true,
      ),
      totalUsers: 2230,
    ),
    Pet(
      id: '5',
      name: 'Luna',
      type: 'Cat',
      breed: 'Maine Coon',
      age: 2,
      gender: 'Female',
      imageUrl: 'assets/images/luna.jpg',
      description: 'Majestic Maine Coon with a friendly personality.',
      personalityTraits: {
        'Friendly': 0.8,
        'Playful': 0.7,
        'Energetic': 0.6,
        'Trainable': 0.5,
        'Good with kids': 0.8,
      },
      medicalHistory: [
        MedicalRecord(
          date: '01/20/2025',
          description: 'General checkup',
          details: 'Healthy and active',
        ),
      ],
      dietaryNeeds: 'Luna is currently on a diet of premium cat food, twice daily. She has no known food allergies and maintains a healthy weight.',
      healthStatus: HealthStatus(
        isVaccinated: true,
        isNeutered: true,
        isMicrochipped: false,
      ),
      totalUsers: 1960,
    ),
    Pet(
      id: '6',
      name: 'Daisy',
      type: 'Dog',
      breed: 'Poodle',
      age: 1,
      gender: 'Female',
      imageUrl: 'assets/images/daisy.jpg',
      description: 'Intelligent and hypoallergenic Poodle puppy.',
      personalityTraits: {
        'Friendly': 0.8,
        'Playful': 0.9,
        'Energetic': 0.8,
        'Trainable': 0.9,
        'Good with kids': 0.8,
      },
      medicalHistory: [
        MedicalRecord(
          date: '03/05/2025',
          description: 'General checkup',
          details: 'Healthy and active',
        ),
      ],
      dietaryNeeds: 'Daisy is currently on a diet of premium puppy food, three times daily. She has no known food allergies and is growing at a healthy rate.',
      healthStatus: HealthStatus(
        isVaccinated: true,
        isNeutered: false,
        isMicrochipped: false,
      ),
      totalUsers: 1720,
    ),
    Pet(
      id: '7',
      name: 'Rocky',
      type: 'Other',
      breed: 'Rabbit',
      age: 1,
      gender: 'Male',
      imageUrl: 'assets/images/rocky.jpg',
      description: 'Friendly dwarf rabbit who loves carrots and cuddles.',
      personalityTraits: {
        'Friendly': 0.7,
        'Playful': 0.6,
        'Energetic': 0.5,
        'Trainable': 0.4,
        'Good with kids': 0.8,
      },
      medicalHistory: [
        MedicalRecord(
          date: '02/25/2025',
          description: 'General checkup',
          details: 'Healthy and active',
        ),
      ],
      dietaryNeeds: 'Rocky needs fresh hay daily, a variety of vegetables, and a limited amount of pellets. He especially enjoys carrots and leafy greens.',
      healthStatus: HealthStatus(
        isVaccinated: true,
        isNeutered: true,
        isMicrochipped: false,
      ),
      totalUsers: 890,
    ),
  ];

  // Get all pets
  List<Pet> getAllPets() {
    return _pets;
  }

  // Get pet by ID
  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get pet by name
  Pet? getPetByName(String name) {
    try {
      return _pets.firstWhere((pet) => pet.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Get pets by type
  List<Pet> getPetsByType(String type) {
    if (type == 'All') {
      return _pets;
    }
    return _pets.where((pet) => pet.type == type).toList();
  }

  // Get pets by breed
  List<Pet> getPetsByBreed(String breed) {
    return _pets.where((pet) => pet.breed.toLowerCase().contains(breed.toLowerCase())).toList();
  }

  // Get pets by age range
  List<Pet> getPetsByAgeRange(int minAge, int maxAge) {
    return _pets.where((pet) => pet.age >= minAge && pet.age <= maxAge).toList();
  }

  // Get pets by gender
  List<Pet> getPetsByGender(String gender) {
    return _pets.where((pet) => pet.gender == gender).toList();
  }

  // Search pets by name or breed
  List<Pet> searchPets(String query) {
    query = query.toLowerCase();
    return _pets.where((pet) =>
    pet.name.toLowerCase().contains(query) ||
        pet.breed.toLowerCase().contains(query) ||
        pet.description.toLowerCase().contains(query)
    ).toList();
  }

  // Sort pets
  List<Pet> sortPets(List<Pet> pets, String sortBy) {
    switch (sortBy) {
      case 'Newest':
      // For demo purposes, we'll just reverse the list
        return List.from(pets.reversed);
      case 'Oldest':
        return pets;
      case 'A-Z':
        return List.from(pets)..sort((a, b) => a.name.compareTo(b.name));
      case 'Z-A':
        return List.from(pets)..sort((a, b) => b.name.compareTo(a.name));
      default:
        return pets;
    }
  }

  // Add a new pet
  void addPet(Pet pet) {
    _pets.add(pet);
  }

  // Update a pet
  void updatePet(Pet pet) {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index != -1) {
      _pets[index] = pet;
    }
  }

  // Delete a pet
  void deletePet(String id) {
    _pets.removeWhere((pet) => pet.id == id);
  }
}