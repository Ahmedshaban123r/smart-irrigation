# 🌱 Smart Precision Irrigation System

AI-powered plant disease detection using TFLite + Raspberry Pi.

---

## 📁 Project Structure

```
Irrigation system/
├── Dockerfile
├── requirements.txt
├── main.py
├── pi_daemon.py
├── model.tflite
├── class_names.json
├── Test_Images/          ← put your leaf images here
│   └── leaf.jpg
└── results/
    └── run_logs.json
```

---

## 🚀 How to Run

### 1. Install Docker Desktop
Download from: https://www.docker.com/products/docker-desktop

### 2. Build the image (once)
```
docker build -t irrigation-system .
```

### 3. Run inference with your image
```
docker run -v "%cd%\results:/app/results" -v "%cd%\Test_Images\YOUR_IMAGE.jpg:/app/test.jpg" irrigation-system

ex:
docker run -v "C:\Users\HP\Desktop\Irrigation system\results:/app/results" -v "C:\Users\HP\Desktop\Irrigation system\Test_Images\leaf.jpg:/app/test.jpg" irrigation-system

```

> Replace `YOUR_IMAGE.jpg` with your leaf image filename inside `Test_Images/`.
> Results will be saved to `results/run_logs.json` automatically.

---

## 📊 Output

Each run logs 50 inferences with:
- Predicted class (Healthy / Early_Blight / Late_Blight / Pest / Nutrient_Deficiency)
- Confidence score
- UART protocol packet
- Inference time (ms)

### Example output:
```
[01/50] Early_Blight   conf=99.61%  proto=0x02  infer=60ms
...
✅ Success Rate   : 100.00% (50/50)
⚡ Avg Inference  : 59.2ms
```

---

## 🔧 Classes & Protocols

| Class               | Protocol | Action              |
|---------------------|----------|---------------------|
| Healthy             | 0x01     | Continue normal     |
| Early Blight        | 0x02     | Reduce irrigation   |
| Late Blight         | 0x03     | Emergency dry       |
| Pest                | 0x04     | Targeted spray      |
| Nutrient Deficiency | 0x05     | Increase irrigation |