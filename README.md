# MealTrack

MealTrack is a cross-platform mobile application designed to streamline inventory management and nutrition tracking. Built with Flutter, it leverages modern cloud technologies and AI to make food tracking as automated as possible.

> **Note:** This is a portfolio project developed to explore modern mobile architecture, offline-first data synchronization, and AI integration.

## Key Features

* **AI-Powered Receipt Scanning**
    Integration of the Google Gemini API to scan shopping receipts via OCR and automatically extract structured item data (JSON) for the inventory.

* **Offline-First Architecture**
    Built on Firebase Firestore with robust offline persistence. Users can track data without an internet connection; sync happens automatically when back online.

* **Cross-Platform**
    Single codebase for Android and iOS using Flutter & Dart.

## Tech Stack & Architecture

This project focuses on clean architecture and modern development practices:

* **Framework:** Flutter (Dart)
* **Backend / Database:** Firebase Firestore (NoSQL), Firebase Authentication
* **AI / ML:** Google Gemini API (Multimodal capabilities for text/image processing)

## Roadmap & Upcoming Features

The project is actively being developed. The following features are planned for the next releases to enhance the "Digital Fridge" experience:

- [ ] **Integrated Shopping List**
      Items that run low in the inventory will be automatically suggested for the shopping list.

- [ ] **Shared Households (Collaboration)**
      Implementation of "Family Mode" using Firebase's real-time capabilities. Multiple users can invite each other to manage a single inventory (e.g., for flatmates or families).

- [ ] **Open Food Facts Integration**
      Integration of public food databases to minimize manual QR code scanning. The goal is to auto-fill nutritional data for a seamless user experience.

- [ ] **Smart Calorie Tracking**
      Implementation of "One-Tap Consumption" logic. Removing an item from the digital fridge will automatically log its calories into the daily nutrition tracker.

- [ ] **AI Chef (Zero-Waste Recipes)**
      Advanced usage of the Gemini API to generate cooking recipes based specifically on the current inventory stock ("What can I cook with what I have?") to reduce food waste.

## Contact

**Wladislaw Repin**
repin@mailbox.org
