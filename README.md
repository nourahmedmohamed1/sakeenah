# 🕋 "Sakina AI" Project 
### The Smart Assistant for Pilgrims (Works 100% Offline)

---

<p align="center">
  <img width="180" height="180" alt="1000132677" src="https://github.com/user-attachments/assets/b2cff724-c5de-4a07-91d7-167a6b5213ce" />

</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Flutter%20%7C%20Dart-02569B?logo=flutter&style=for-the-badge" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Connectivity-100%25%20Offline-success?style=for-the-badge" alt="100% Offline"/>
</p>

---

## 📌 About the Project
This project aims to assist and guide pilgrims during the Hajj journey; it handles guiding the pilgrim and determining their path if they get lost, in addition to sending automated distress messages in cases of fainting or health emergencies.

The final vision of the project is based on operating **completely 100% offline**, to overcome the problem of network disconnection or weakness resulting from crowd density. The app integrates:
* AI technologies based on phone sensors.
* Offline geographic information systems (GIS).
* Smart navigation.

---

##  Targeted Features & Mechanism of Action

### 🗺️ 1. True Offline Guidance and Navigation System
* **Feature:** Provides a real-time navigation system that draws a colored path to guide the pilgrim through actual streets and alleys to reach the nearest medical facility or ambulance point.
* **Mechanism of Action:** Integrating a local road network based on shortest path determination algorithms that work instantly in the phone's background without the need for the internet.

### ⚡ 2. Automatic Route Update Upon Deviation
* **Feature:** If the pilgrim deviates from the drawn path, the map updates its route instantly to draw a new path starting from their current location.
* **Mechanism of Action:** Comparing GPS coordinates with the specified path; if the distance exceeds 30 meters, it automatically recalculates the new path in fractions of a second.

### 🚨 3. Smart Distress and Emergency Management System
A protection system divided into three levels based on the health condition to ensure rapid rescue and avoid random alerts:
* **Level 1 (Heat exhaustion or dizziness):** Upon detecting a state of instability without falling, the application guides the pilgrim audio-visually to the nearest medical facility.
* **Level 2 (Manual distress):** An emergency button that works via a long press to avoid accidental activation, sending an immediate distress message to the supervisor containing the pilgrim's identity and precise location.
* **Level 3 (Critical condition):** Upon detecting a violent fall or loss of consciousness, the application automatically sends an urgent distress message to the supervisor with the location coordinates and activates voice navigation.

### 📿 4. Full Automation of the Smart Tawaf Counter
* **Feature:** Calculates the number of rounds automatically without audio distraction; it replaces alerts with light vibrations upon the completion of each round, and contents itself with an audio alert in the seventh (last) round to alert the pilgrim.
* **Mechanism of Action:** It relies on tracking the cumulative angle by reading real-time data from the built-in compass sensor in the phone. Upon completion of each cycle at a rate of 360 degrees and its multiples, the counter increases automatically until the completion of the seven rounds (2520 degrees) to trigger an audio alert.

### 🔍 5. High-Definition Offline Map Processing
* **Feature:** Supports high zoom levels to show the finest details of streets and camps to prevent the pilgrim from getting lost in narrow alleys.
* **Mechanism of Action:** Preparing the geographic atlas in advance and reading map tiles from the internal storage memory immediately upon installing the application to ensure complete smoothness.

---

## 📸 App Showcase (UI/UX)
<table width="100%">
  <tr>
    <td align="center">
      <br/><em><img width="200" height="400" alt="1000132681" src="https://github.com/user-attachments/assets/c8884556-464d-4547-8523-35c0f03d7aed" />
</em>
    </td>
    <td align="center">
      <br/><em><img width="200" height="400" alt="1000132679" src="https://github.com/user-attachments/assets/75a96742-0c40-4374-aa88-05cb8599a258" />
</em>
    </td>
    <td align="center">
      <br/><em><img width="200" height="400" alt="1000132680" src="https://github.com/user-attachments/assets/917081a0-5121-48af-8aae-e857b43b1aa9" />
</em>
    </td>    
    <td align="center">
      <br/><em><img width="200" height="400" alt="1000132678" src="https://github.com/user-attachments/assets/79f88ba3-4954-486f-b439-fdca7f8e9b7c" />
</em>
    </td>
  </tr>
</table>

---

## 🤝 Project Contributors
Meet the brilliant minds behind **Sakina AI**. Feel free to connect with us!

| Developer Name | GitHub | LinkedIn |
| :--- | :---: | :---: |
| **Jody Ahmed** | <a href="LINK_HERE"><img src="https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white" alt="GitHub"/></a> | <a href="LINK_HERE"><img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white" alt="LinkedIn"/></a> |
| **Rojan Hamdy** | <a href="LINK_HERE"><img src="https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white" alt="GitHub"/></a> | <a href="LINK_HERE"><img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white" alt="LinkedIn"/></a> |
| **Nour Ahmed** | <a href="LINK_HERE"><img src="https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white" alt="GitHub"/></a> | <a href="www.linkedin.com/in/nn-anwar"><img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white" alt="LinkedIn"/></a> |

---

> 💡 **"Sakina AI" is not just an idea; it is a project aimed at saving the lives of the guests of Allah and protecting their data privacy.**
