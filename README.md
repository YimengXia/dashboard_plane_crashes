#  ✈️ Plane Crashes 

## 🌟 Motivation

Target Audience: Aviation Enthusiasts

Aviation enthusiasts often have a profound interest in understanding the dynamics and safety aspects of flying. Through this data visualization app, the aim is to cater to aviation lovers by providing them with comprehensive insights into historical plane crash data. By exploring variables such as the phase of flight, type of flight, causes of crashes, and survivor statistics, users can gain a deeper appreciation of the factors contributing to aviation safety. The app enables users to filter and analyze data based on specific interests, whether they are curious about the safety records of commercial versus military flights, the commonalities in crash causes, or the survival rates across different incidents. Ultimately, this app seeks to enrich aviation enthusiasts' knowledge and perhaps even contribute to broader discussions and learnings about flight safety and prevention strategies.

## 🔧 Installation instructions
1. 📥 Open your terminal, and run the following command to clone this repository:
```shell
git clone https://github.com/YimengXia/dashboard_plane_crashes.git
cd dashboard_plane_crashes
```
2. Install Conda Environment
```shell
conda env create -f environment.yml
```
3. Activate the Environment
```shell
conda activate plane_crashes
```
4. Navigate to the directory containing the app
```shell
cd src
```
5. Use the following command to run the app:
```shell
R -e "shiny::runApp()"
```
6. Accessing the App

Once the app is running, open a web browser and navigate to the address indicated in the terminal (something like http://127.0.0.1:XXXX).
