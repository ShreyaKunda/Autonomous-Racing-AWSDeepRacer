# 🏁 DRL-Autonomous-Racing-AWSDeepRacer

This repository contains the code, reward functions, and results for our research paper titled:

**"Reward Design and Hyperparameter Tuning for Generalizable Deep Reinforcement Learning Agents in Autonomous Racing"**  
📄 Published in: IEEE Access (DOI: [10.1109/ACCESS.2024.0429000](https://doi.org/10.1109/ACCESS.2024.0429000))

## 📚 Abstract

We explore the interplay between reward engineering and hyperparameter tuning for autonomous racing using DRL algorithms. Using AWS DeepRacer as our platform, we performed extensive comparative experiments with PPO and SAC across different reward strategies and hyperparameter configurations.

## 🔍 Key Contributions

- Comparative analysis of PPO vs SAC on AWS DeepRacer
- Design of two structured reward functions
- Hyperparameter optimization: Batch size, learning rate, discount factor, entropy
- Evaluation on 21 unseen tracks showing high generalization performance

## 🚗 Environment

- AWS DeepRacer
- PPO & SAC (Stable-Baselines3)
- Python 3.8+

## 🧠 Algorithms

- Proximal Policy Optimization (PPO)
- Soft Actor-Critic (SAC)

## 📁 Structure

- `src/reward_functions/`: Contains both reward function implementations.
- `src/training/`: Code to train models using PPO and SAC.
- `results/`: Evaluation results on unseen tracks.
- `report/`: Full IEEE Access paper for reference.

## 🛠 Requirements

Install dependencies using:

```bash
pip install -r requirements.txt
