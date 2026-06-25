# Domain-Shift Robustness — ML Pipeline Enhancement Plan (v2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the domain gap between lab/field training images and real Pi-camera exhibition conditions. Drop Pest (unreliable IP102) and Nutrient_Deficiency (Maize NPK = wrong crop). Go to 3 classes (Healthy, Early_Blight, Late_Blight) + entropy-based Unknown. Validate with actual Pi camera captures.

**Architecture:** Rewrite `embedded-project-v2.ipynb` from scratch (Kaggle notebook). Three layers of defense: (1) clean 3-class dataset with background randomization on PlantVillage lab portion, (2) retrain + requantize, (3) validate with real Pi camera images of printed leaves. Pi daemon gets temporal smoothing for inference-time stability.

**Tech Stack:** TensorFlow 2.x, Keras, PIL, OpenCV (Kaggle GPU). Python 3.11 on Pi. Existing Firebase protocol.

**Base notebook:** `embedded-project-v2.ipynb` — rebuilt from scratch with PlantVillage (lab) + PlantDoc (field) only. No IP102, no Maize NPK.

## Global Constraints

- Never touch graded artefacts: `pic-firmware/`, `esp-firmware/`, `default.hex`, `Report and Feasibilty Study/`
- Notebook runs on **Kaggle** (paths: `/kaggle/input/`, `/kaggle/working/`)
- Pi daemon lives in `pi-ai/Irrigation system/Docker_files/pi_daemon.py`
- Model output: INT8 TFLite, **3-class** schema (`Early_Blight, Healthy, Late_Blight`) + entropy-based Unknown fallback
- UART protocol removed from notebook — lives only in pi_daemon.py
- Firebase schema unchanged (`/ai/latest_detection/`)
- Target: >90% accuracy on held-out test set, >85% on Pi-camera reference set, <200ms inference on Pi
- Pi camera: USB webcam via `fswebcam` at 1920x1080, JPEG 95% (see `pi-ai/Capture_camera/capture_and_infer.sh`)
- Pi user: `robox`, files at `/home/robox/Final_Project/`

## What's Already Done (in embedded-project-v2.ipynb)

- 3-class dataset: PlantVillage (lab) + PlantDoc (field), no IP102/Maize
- Background randomization on PlantVillage lab images (DTD textures)
- MobileNetV2 transfer learning with augmentation (flip, rotate, zoom, brightness, contrast, translate)
- Label smoothing (0.1), Dropout(0.4)
- Entropy calibration for Unknown fallback
- INT8 TFLite quantization pipeline
- Class weights for imbalanced data
- UART protocol removed from notebook (lives in daemon only)

## What This Plan Adds (remaining tasks)

1. ~~Drop Pest + Nutrient_Deficiency → 3 classes~~ **DONE** (notebook rebuilt)
2. ~~Background randomization on PlantVillage lab images~~ **DONE**
3. ~~Label smoothing + dropout tuning~~ **DONE**
4. Pi camera reference set capture (physical testing) — Task 5
5. Few-shot fine-tuning on camera images (conditional) — Task 6
6. Temporal smoothing in Pi daemon — Task 7
7. V1 vs V2 comparison across all eval sets — Task 8

---

### Task 1: ~~Drop Pest + Nutrient_Deficiency, Build 3-Class Background-Randomized Dataset~~ DONE

**Why:** IP102 pest images are 102 generic insect macro photos — completely different domain from what Pi camera sees. Model confidently misclassifies random inputs as Pest. Dropping it and letting entropy catch unknowns is more honest. Background randomization on PlantVillage lab images forces model to learn leaf features, not white backgrounds.

**Files:**
- Modify: `embedded-project.ipynb` cells 1–5

**Interfaces:**
- Consumes: PlantVillage, PlantDoc, Maize NPK datasets (already attached in Kaggle)
- Produces: `/kaggle/working/dataset/` with 4 class folders, ~2500 images each

- [ ] **Step 1: Install albumentations (new cell after cell 0)**

```python
!pip install albumentations --quiet
import albumentations as A
import cv2
```

- [ ] **Step 2: Modify cell 1 — remove IP102 path**

Remove these lines from cell 1:
```python
IP102_ROOT        = f'{BASE}/rtlmhjbn/ip02-dataset'
IP102_TRAIN_DIR   = f'{IP102_ROOT}/classification/train'
```

And remove IP102 from the verification prints. Also remove the IP102 Kaggle dataset attachment from the notebook sidebar.

- [ ] **Step 3: Modify cell 2 — remove Pest class, remove IP102 references**

Replace `CLASSES` definition:

```python
CLASSES = ['Early_Blight', 'Healthy', 'Late_Blight']
```

Remove all IP102/Pest references. Keep PlantVillage, PlantDoc, and Maize NPK mappings as-is.

- [ ] **Step 4: Add background randomization functions (new cell after cell 2)**

```python
def segment_leaf(img_pil, threshold=220):
    """Segment leaf from PlantVillage white/light background."""
    img_np = np.array(img_pil)
    gray = cv2.cvtColor(img_np, cv2.COLOR_RGB2GRAY)
    _, mask = cv2.threshold(gray, threshold, 255, cv2.THRESH_BINARY_INV)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel, iterations=2)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel, iterations=1)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return img_pil, None
    largest = max(contours, key=cv2.contourArea)
    clean_mask = np.zeros_like(mask)
    cv2.drawContours(clean_mask, [largest], -1, 255, -1)
    return img_pil, clean_mask


def paste_on_background(leaf_pil, mask, bg_pil, target_size=256):
    """Paste segmented leaf onto random background with random scale/position."""
    bg = bg_pil.resize((target_size, target_size)).convert('RGB')
    scale = random.uniform(0.5, 0.9)
    new_size = int(target_size * scale)
    leaf_resized = leaf_pil.resize((new_size, new_size))
    mask_pil = Image.fromarray(mask).resize((new_size, new_size))
    max_offset = target_size - new_size
    x = random.randint(0, max(0, max_offset))
    y = random.randint(0, max(0, max_offset))
    bg.paste(leaf_resized, (x, y), mask_pil)
    return bg


def is_plantvillage(img_path):
    """Check if image comes from PlantVillage (lab) based on path."""
    return 'plantvillage' in str(img_path).lower()


# Download DTD textures for backgrounds
import urllib.request, tarfile
DTD_DIR = '/kaggle/working/dtd_textures'
if not os.path.exists(DTD_DIR):
    print("Downloading DTD textures for background randomization...")
    urllib.request.urlretrieve(
        'https://www.robots.ox.ac.uk/~vgg/data/dtd/download/dtd-r1.0.1.tar.gz',
        '/tmp/dtd.tar.gz')
    with tarfile.open('/tmp/dtd.tar.gz') as tar:
        tar.extractall('/kaggle/working/')
    os.rename('/kaggle/working/dtd/images', DTD_DIR)
    print(f"DTD textures: {len(list(Path(DTD_DIR).rglob('*.jpg')))} images")

bg_paths = list(Path(DTD_DIR).rglob('*.jpg'))
print(f"Background images available: {len(bg_paths)}")

# Test segmentation
sample = list(Path(PLANTVILLAGE_BASE).rglob('*.jpg'))[0]
_, test_mask = segment_leaf(Image.open(sample).convert('RGB'))
if test_mask is not None:
    coverage = np.sum(test_mask > 0) / test_mask.size * 100
    print(f"Test segmentation: {coverage:.1f}% mask coverage")
```

- [ ] **Step 5: Modify cell 3 — add background swap for PlantVillage images**

Replace the copy loop in cell 3. After gathering `class_images` for all 3 classes (PlantVillage + PlantDoc + Maize), add background randomization for PlantVillage-sourced images:

```python
ORIG_KEEP_RATIO = 0.3  # keep 30% original lab images, swap 70%

print(f"\n=== Copying with bg randomization (cap {MAX_PER_CLASS}/class) ===")
copied = {}

for cls in CLASSES:
    imgs = class_images[cls]
    random.shuffle(imgs)
    imgs = imgs[:MAX_PER_CLASS]

    # Split PlantVillage (lab) vs field images
    lab_imgs = [p for p in imgs if is_plantvillage(p)]
    field_imgs = [p for p in imgs if not is_plantvillage(p)]

    n_lab_orig = int(len(lab_imgs) * ORIG_KEEP_RATIO)
    n = 0

    # Field images: copy as-is (already diverse backgrounds)
    for i, img_path in enumerate(field_imgs):
        dst = Path(OUTPUT_DIR) / cls / f"{n:05d}_field_{img_path.name}"
        if not dst.exists():
            shutil.copy(img_path, dst)
        n += 1

    # Lab images: 30% original, 70% background-swapped
    for i, img_path in enumerate(lab_imgs):
        img = Image.open(img_path).convert('RGB')

        if i < n_lab_orig:
            # Keep original
            out = img.resize((256, 256))
        else:
            # Background swap
            leaf_img, mask = segment_leaf(img)
            if mask is not None and np.sum(mask > 0) > 1000:
                bg = Image.open(random.choice(bg_paths)).convert('RGB')
                out = paste_on_background(leaf_img, mask, bg)
            else:
                out = img.resize((256, 256))

        dst = Path(OUTPUT_DIR) / cls / f"{n:05d}_lab_{img_path.name}"
        out.save(dst, quality=90)
        n += 1

    copied[cls] = n
    lab_swapped = max(0, len(lab_imgs) - n_lab_orig)
    bar = '#' * (n // 100)
    print(f"  {cls:<22} {n:>5}  (field:{len(field_imgs)} lab-orig:{n_lab_orig} lab-swapped:{lab_swapped})  {bar}")

total = sum(copied.values())
print(f"\nTotal: {total} images")
```

- [ ] **Step 6: Update visualization cell (cell 5) and verify 3 classes**

Run cells 4-5 as-is. Verify:
- Only 4 class folders in bar chart (no Pest)
- Sample images show mix of field photos + bg-swapped lab photos

---

### Task 2: ~~Retrain 3-Class Model with Label Smoothing~~ DONE (in notebook)

**Why:** Fewer classes = tighter decision boundaries. Label smoothing prevents overconfidence, which helps entropy-based Unknown detection work better. Dropout 0.4 instead of 0.6 since background randomization already regularizes.

**Files:**
- Modify: `embedded-project.ipynb` cells 6–14

**Interfaces:**
- Consumes: `/kaggle/working/dataset/` (3-class, from Task 1)
- Produces: `best_model.keras`, `final_model.keras`, training history, confusion matrix, entropy threshold

- [ ] **Step 1: Modify cell 6 — update NUM_CLASSES**

```python
NUM_CLASSES = 3
```

Rest of cell 6 unchanged (train/val/test split).

- [ ] **Step 2: Modify cell 8 — update model head**

Change dropout from 0.6 to 0.4:

```python
x = layers.Dropout(0.4)(x)
```

`NUM_CLASSES` is already referenced in the Dense layer — will pick up 4 automatically.

- [ ] **Step 3: Modify cell 10 — add label smoothing**

Replace loss function:

```python
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),
    loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1),
    metrics=['accuracy'],
)
```

Increase patience to 5 and epochs to 25:

```python
callbacks = [
    EarlyStopping(monitor='val_accuracy', patience=5, restore_best_weights=True, verbose=1),
    ModelCheckpoint(filepath=CHECKPOINT_PATH, monitor='val_accuracy', save_best_only=True, verbose=1),
    ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=2, min_lr=1e-6, verbose=1),
]

history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=25,
    callbacks=callbacks,
    class_weight=class_weight_dict,
    verbose=1,
)
```

- [ ] **Step 4: Modify cell 13 — entropy calibration with 3 classes**

Entropy formula already uses `len(CLASS_NAMES)` — will normalize correctly for 3 classes. No code change needed, just verify output makes sense. The threshold will likely shift since 3-class entropy is normalized differently than 5-class.

- [ ] **Step 5: Run cells 6-14, record results**

Record:
- Best val accuracy
- Test accuracy
- ENTROPY_THRESHOLD value
- Confusion matrix (should be 4×4 now)

---

### Task 3: ~~Quantize to INT8 TFLite and Validate~~ DONE (in notebook)

**Why:** Must deploy as INT8 TFLite on Pi. Verify quantization doesn't degrade 3-class accuracy.

**Files:**
- Modify: `embedded-project.ipynb` cells 16–20

**Interfaces:**
- Consumes: `best_model.keras` (from Task 2), val split for calibration, test split for evaluation
- Produces: `model.tflite`, `tflite_summary.json`

- [ ] **Step 1: Run cells 16-20 as-is**

Quantization pipeline is unchanged. Just verify:
- TFLite accuracy drop <2pp from Keras accuracy
- Model size <4MB
- Record `in_scale`, `in_zero_point`, `out_scale`, `out_zero_point`

- [ ] **Step 2: Update cell 20 — num_classes = 4**

```python
summary = {
    ...
    'num_classes': 4,
}
```

---

### Task 4: ~~Update Daemon for 3 Classes~~ PENDING (daemon update needed separately)

**Why:** Daemon CLASS_NAMES must match 3-class model. Entropy threshold may have changed. UART protocol removed from notebook — daemon is the only place it lives.

**Files:**
- Modify: `pi-ai/Irrigation system/Docker_files/pi_daemon.py`

**Interfaces:**
- Consumes: New ENTROPY_THRESHOLD from notebook training, 3-class model
- Produces: Updated pi_daemon.py with 3 classes

- [ ] **Step 1: Update pi_daemon.py CLASS_NAMES to 3 classes**

```python
CLASS_NAMES = ["Early_Blight", "Healthy", "Late_Blight"]
```

Remove all Nutrient_Deficiency and Pest references. Update entropy normalization to `np.log(3)`.

- [ ] **Step 2: Update ENTROPY_THRESHOLD with new value from notebook cell 13**

- [ ] **Step 3: Commit**

```bash
git add "pi-ai/Irrigation system/Docker_files/pi_daemon.py"
git commit -m "feat: update daemon to 3-class model

3 classes: Healthy, Early_Blight, Late_Blight. Pest (IP102) and
Nutrient_Deficiency (Maize NPK) removed — wrong domains. Unknowns
caught by entropy threshold."
```

---

### Task 5: Capture Pi Camera Reference Set (Physical Testing)

**Why:** Software augmentation does NOT replicate real camera behavior. Pi camera has lens distortion, auto white balance, fixed-focus blur, `fswebcam` JPEG artifacts, exhibition ambient lighting. This is the **ground truth acceptance test**.

**Files:**
- Create: `ml-pipeline/pi_camera_ref/capture_reference.sh` (on Pi)
- Create: `ml-pipeline/pi_camera_ref/evaluate_reference_set.py`
- Output: `ml-pipeline/pi_camera_ref/{class}/` — ~8-12 images per class from Pi camera

**Interfaces:**
- Consumes: Printed leaf disease images, Pi camera via `fswebcam`, model.tflite from Task 3
- Produces: Pi camera reference images + evaluation results JSON

**Prerequisites:** Color printer. Pi with USB webcam connected.

- [ ] **Step 1: Prepare printable leaf images**

On Windows, save 3 representative images per class from Google Images:

| Class | Search terms |
|---|---|
| Healthy | "healthy tomato leaf", "healthy potato leaf", "healthy pepper leaf" |
| Early_Blight | "early blight tomato leaf", "early blight potato" |
| Late_Blight | "late blight tomato", "late blight potato leaf" |

Save 3 images per class → 9 total. Print on A4 paper (color, normal quality). Cut out roughly.

- [ ] **Step 2: Create capture script on Pi**

```bash
ssh robox@<PI_IP>
mkdir -p /home/robox/Final_Project/pi_camera_ref/{Healthy,Early_Blight,Late_Blight}
```

Create `/home/robox/Final_Project/capture_reference.sh`:

```bash
#!/bin/bash
CLASS="$1"
NUM="$2"
BASE="/home/robox/Final_Project/pi_camera_ref"

if [ -z "$CLASS" ] || [ -z "$NUM" ]; then
    echo "Usage: $0 <class_name> <number>"
    echo "Classes: Healthy, Early_Blight, Late_Blight"
    exit 1
fi

mkdir -p "$BASE/$CLASS"

for VARIANT in straight angled close; do
    OUTFILE="$BASE/$CLASS/${CLASS}_${NUM}_${VARIANT}.jpg"
    echo "Position printed leaf ($VARIANT view), then press Enter..."
    read -r
    fswebcam -d /dev/video0 -r 1920x1080 --no-banner --jpeg 95 --skip 30 --delay 2 "$OUTFILE"
    echo "Saved: $OUTFILE"
done

echo "Done. $CLASS image $NUM captured (3 variants)."
```

```bash
chmod +x /home/robox/Final_Project/capture_reference.sh
```

- [ ] **Step 3: Capture reference images**

For each printed image, capture 3 variants (straight, angled, close-up). Also vary lighting:
- Room lights on (bright)
- Desk lamp only (directional shadows)
- Phone flashlight (harsh)

```bash
cd /home/robox/Final_Project
./capture_reference.sh Healthy 1
./capture_reference.sh Healthy 2
./capture_reference.sh Healthy 3
# ... repeat for all 3 classes, all 3 images each
```

Target: ~27-36 images total (3 images × 3 variants × 3 classes, some with lighting changes).

- [ ] **Step 4: Copy reference set to Windows**

```powershell
scp -r robox@<PI_IP>:/home/robox/Final_Project/pi_camera_ref "ml-pipeline/pi_camera_ref"
```

- [ ] **Step 5: Create evaluation script**

Create `ml-pipeline/pi_camera_ref/evaluate_reference_set.py`:

```python
#!/usr/bin/env python3
"""Evaluate TFLite model on Pi camera reference images."""
import json, sys, os
import numpy as np
from pathlib import Path
from PIL import Image
from collections import defaultdict

try:
    from ai_edge_litert.interpreter import Interpreter
except ImportError:
    try:
        import tflite_runtime.interpreter as tflite_mod
        Interpreter = tflite_mod.Interpreter
    except ImportError:
        import tensorflow as tf
        Interpreter = tf.lite.Interpreter

MODEL_PATH = sys.argv[1] if len(sys.argv) > 1 else "model.tflite"
REF_DIR = sys.argv[2] if len(sys.argv) > 2 else "pi_camera_ref"
IMG_SIZE = 224
CLASS_NAMES = ['Early_Blight', 'Healthy', 'Late_Blight']

interpreter = Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()
inp = interpreter.get_input_details()[0]
out = interpreter.get_output_details()[0]
in_scale, in_zp = inp['quantization']
out_scale, out_zp = out['quantization']

results = defaultdict(lambda: {'correct': 0, 'total': 0, 'predictions': []})

for cls_dir in sorted(Path(REF_DIR).iterdir()):
    if not cls_dir.is_dir() or cls_dir.name not in CLASS_NAMES:
        continue
    true_class = cls_dir.name

    for img_path in sorted(cls_dir.glob("*.jpg")):
        img = Image.open(img_path).convert("RGB").resize((IMG_SIZE, IMG_SIZE))
        arr = np.array(img, dtype=np.float32)
        arr_int8 = np.round(arr / in_scale + in_zp).clip(-128, 127).astype(np.int8)

        interpreter.set_tensor(inp['index'], arr_int8[np.newaxis])
        interpreter.invoke()
        logits = (interpreter.get_tensor(out['index']).astype(np.float32) - out_zp) * out_scale
        exp_l = np.exp(logits - logits.max())
        probs = (exp_l / exp_l.sum()).flatten()

        pred_idx = int(np.argmax(probs))
        pred_class = CLASS_NAMES[pred_idx]
        conf = float(probs[pred_idx])

        # Entropy check
        p = np.clip(probs, 1e-9, 1.0)
        entropy = float(-np.sum(p * np.log(p)) / np.log(len(CLASS_NAMES)))

        correct = pred_class == true_class
        results[true_class]['total'] += 1
        if correct:
            results[true_class]['correct'] += 1
        results[true_class]['predictions'].append({
            'file': img_path.name,
            'predicted': pred_class,
            'confidence': round(conf, 3),
            'entropy': round(entropy, 3),
            'correct': correct,
        })

        status = "OK" if correct else "WRONG"
        print(f"  [{status}] {img_path.name}: pred={pred_class} ({conf:.1%}, ent={entropy:.3f}) true={true_class}")

print("\n" + "=" * 60)
total_correct = sum(r['correct'] for r in results.values())
total_images = sum(r['total'] for r in results.values())
overall_acc = total_correct / total_images if total_images > 0 else 0

print(f"OVERALL: {total_correct}/{total_images} = {overall_acc:.1%}")
print()
for cls in CLASS_NAMES:
    r = results[cls]
    if r['total'] > 0:
        acc = r['correct'] / r['total']
        print(f"  {cls:<22}: {r['correct']}/{r['total']} = {acc:.0%}")

print(f"\n{'PASS' if overall_acc >= 0.85 else 'FAIL'} (target: >=85%)")

with open(Path(REF_DIR) / "evaluation_results.json", "w") as f:
    json.dump({
        'overall_accuracy': round(overall_acc, 4),
        'per_class': {cls: {
            'accuracy': round(r['correct'] / r['total'], 4) if r['total'] > 0 else 0,
            'correct': r['correct'],
            'total': r['total'],
            'predictions': r['predictions'],
        } for cls, r in results.items()},
        'model': MODEL_PATH,
        'num_classes': len(CLASS_NAMES),
        'pass': overall_acc >= 0.85,
    }, f, indent=2)
print(f"\nResults saved to {REF_DIR}/evaluation_results.json")
```

- [ ] **Step 6: Run evaluation on Pi**

```bash
cd /home/robox/Final_Project
python3 evaluate_reference_set.py model.tflite pi_camera_ref
```

- [ ] **Step 7: Record results and decide**

Read `evaluation_results.json`:
- **>=85%:** Skip Task 6. Proceed to Task 7.
- **<85%:** Run Task 6 (few-shot fine-tuning).

---

### Task 6: Few-Shot Fine-Tune on Pi Camera Domain (Conditional)

**SKIP if Task 5 achieves >=85% accuracy.**

**Why:** If real camera images score <85%, domain gap is too wide for augmentation alone. Fine-tuning only the last Dense layer on ~30-50 real camera images adapts the model without destroying learned disease features.

**Files:**
- Modify: `embedded-project.ipynb` (add cells after cell 14, before quantization)
- Input: Pi camera reference images uploaded to Kaggle
- Output: `best_model_finetuned.keras`

**Interfaces:**
- Consumes: `best_model.keras` (from Task 2), Pi camera reference images (from Task 5)
- Produces: Fine-tuned Keras model, re-quantized TFLite

- [ ] **Step 1: Upload Pi camera reference set to Kaggle**

Upload `ml-pipeline/pi_camera_ref/` as a Kaggle dataset or copy to `/kaggle/working/pi_camera_ref/`.

```python
PI_CAM_DIR = '/kaggle/working/pi_camera_ref'  # or Kaggle dataset path

for cls in sorted(os.listdir(PI_CAM_DIR)):
    cls_path = Path(PI_CAM_DIR) / cls
    if cls_path.is_dir():
        n = len(list(cls_path.glob('*.jpg')))
        print(f"  {cls}: {n} images")
```

- [ ] **Step 2: Fine-tune last layer only (new cell)**

```python
model_ft = tf.keras.models.load_model(CHECKPOINT_PATH)

# Freeze everything except final Dense
for layer in model_ft.layers[:-1]:
    layer.trainable = False
model_ft.layers[-1].trainable = True

print(f"Trainable layers: {sum(1 for l in model_ft.layers if l.trainable)}")

pi_cam_ds = tf.keras.utils.image_dataset_from_directory(
    PI_CAM_DIR,
    image_size=(IMG_SIZE, IMG_SIZE),
    batch_size=4,
    label_mode='categorical',
    shuffle=True,
)

total_batches = len(pi_cam_ds)
ft_train = pi_cam_ds.take(int(total_batches * 0.8))
ft_test = pi_cam_ds.skip(int(total_batches * 0.8))
ft_train = ft_train.cache().prefetch(AUTOTUNE)
ft_test = ft_test.cache().prefetch(AUTOTUNE)

FT_CHECKPOINT = f'{DRIVE_BASE}/best_model_finetuned.keras'

model_ft.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5),
    loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1),
    metrics=['accuracy'],
)

ft_history = model_ft.fit(
    ft_train,
    validation_data=ft_test,
    epochs=10,
    callbacks=[
        EarlyStopping(monitor='val_accuracy', patience=3, restore_best_weights=True, verbose=1),
        ModelCheckpoint(filepath=FT_CHECKPOINT, monitor='val_accuracy', save_best_only=True, verbose=1),
    ],
    verbose=1,
)

# Check test set didn't regress
_, ft_test_acc = model_ft.evaluate(test_ds, verbose=0)
print(f"\nPost-finetune test accuracy: {ft_test_acc:.4f}")
print(f"Pre-finetune test accuracy:  {keras_acc:.4f}")
regression = keras_acc - ft_test_acc
print(f"Regression: {regression*100:.1f}pp {'OK (<3pp)' if regression < 0.03 else 'WARNING'}")
```

- [ ] **Step 3: Re-quantize fine-tuned model**

Replace `MODEL_PATH` in cell 16 with `FT_CHECKPOINT`, then re-run cells 16-20 to get new TFLite.

- [ ] **Step 4: Deploy and re-test on Pi**

```bash
scp model.tflite robox@<PI_IP>:/home/robox/Final_Project/model.tflite
ssh robox@<PI_IP> "cd /home/robox/Final_Project && python3 evaluate_reference_set.py model.tflite pi_camera_ref"
```

---

### Task 7: Add Temporal Smoothing to Pi Daemon

**Why:** Single-frame predictions are noisy. Sliding window majority-vote smooths over bad frames.

**Files:**
- Modify: `pi-ai/Irrigation system/Docker_files/pi_daemon.py`

**Interfaces:**
- Consumes: Per-frame predictions (class name + confidence)
- Produces: Smoothed prediction used for UART + Firebase

- [ ] **Step 1: Add PredictionSmoother class**

After `PROTOCOL_PARAMS` dict, add:

```python
from collections import deque

class PredictionSmoother:
    def __init__(self, window_size=5):
        self.window_size = window_size
        self.history = deque(maxlen=window_size)

    def update(self, class_name, confidence):
        self.history.append((class_name, confidence))
        if len(self.history) < 2:
            return class_name, confidence
        votes = {}
        for cls, conf in self.history:
            if cls not in votes:
                votes[cls] = {'count': 0, 'total_conf': 0.0}
            votes[cls]['count'] += 1
            votes[cls]['total_conf'] += conf
        winner = max(votes, key=lambda c: (votes[c]['count'], votes[c]['total_conf']))
        avg_conf = votes[winner]['total_conf'] / votes[winner]['count']
        return winner, avg_conf
```

- [ ] **Step 2: Wire into main loop**

Add `--smooth-window` argument:

```python
parser.add_argument("--smooth-window", type=int, default=5,
                    help="Temporal smoothing window size (1=disabled)")
```

After `logger.info("Entering main loop...")`:

```python
    smoother = PredictionSmoother(window_size=args.smooth_window)
    logger.info(f"Temporal smoothing: window={args.smooth_window}")
```

Replace inference line:

```python
        raw_class, raw_confidence, entropy = run_inference(
            interpreter, input_det, output_det, image)
        predicted_class, confidence = smoother.update(raw_class, raw_confidence)

        logger.info(
            f"[#{inference_count}] Raw: {raw_class} ({raw_confidence:.2%}) | "
            f"Smoothed: {predicted_class} ({confidence:.2%}) | "
            f"Entropy: {entropy:.3f} | Inference: {inference_ms:.0f}ms"
        )
```

- [ ] **Step 3: Also update daemon code in cell 23 of notebook**

Add same `PredictionSmoother` class and wiring to the daemon code string in the notebook so the generated `pi_daemon.py` matches.

- [ ] **Step 4: Commit**

```bash
git add "pi-ai/Irrigation system/Docker_files/pi_daemon.py"
git commit -m "feat: add temporal smoothing + drop Pest class in daemon

3-class model (no Pest). Sliding window majority-vote smoother
(default window=5). Configurable via --smooth-window."
```

---

### Task 8: Compare V1 vs V2 and Document Results

**Why:** Quantify improvement across all dimensions for exhibition and report.

**Files:**
- Modify: `embedded-project.ipynb` (add comparison cells at end)
- Output: Charts + JSON saved to Kaggle working dir

**Interfaces:**
- Consumes: V1 metrics (5-class, from `Model (1).ipynb`), V2 model (3-class), Pi camera reference set
- Produces: Comparison summary for report

- [ ] **Step 1: Evaluate V1 on test set (new cell)**

```python
# V1 model has 5 classes — can't directly compare on 3-class test set.
# Instead, compare on the 4 shared classes only.
# Load V1 if available on Drive, otherwise report V1 metrics from training logs.

V1_METRICS = {
    'test_accuracy_5class': 0.9786,       # from Model (1).ipynb
    'tflite_accuracy_5class': 0.9704,     # from Model (1).ipynb
    'classes': 5,
    'bg_randomization': False,
    'label_smoothing': False,
    'field_images_mixed': False,
    'entropy_unknown': False,
    'temporal_smoothing': False,
}

V2_METRICS = {
    'test_accuracy_4class': float(keras_acc),
    'tflite_accuracy_4class': float(tflite_acc),
    'classes': 3,
    'bg_randomization': True,
    'label_smoothing': 0.1,
    'field_images_mixed': True,
    'entropy_unknown': True,
    'entropy_threshold': float(ENTROPY_THRESHOLD),
    'temporal_smoothing': True,
}

print("=" * 60)
print("V1 vs V2 COMPARISON")
print("=" * 60)
print(f"{'Metric':<30} {'V1':>10} {'V2':>10}")
print("-" * 60)
print(f"{'Classes':<30} {'5':>10} {'3':>10}")
print(f"{'Test Accuracy':<30} {V1_METRICS['test_accuracy_5class']:>9.1%} {V2_METRICS['test_accuracy_4class']:>9.1%}")
print(f"{'TFLite Accuracy':<30} {V1_METRICS['tflite_accuracy_5class']:>9.1%} {V2_METRICS['tflite_accuracy_4class']:>9.1%}")
print(f"{'BG Randomization':<30} {'No':>10} {'Yes':>10}")
print(f"{'Field Images Mixed':<30} {'No':>10} {'Yes':>10}")
print(f"{'Label Smoothing':<30} {'No':>10} {'0.1':>10}")
print(f"{'Entropy Unknown':<30} {'No':>10} {'Yes':>10}")
print(f"{'Temporal Smoothing':<30} {'No':>10} {'Yes':>10}")
print("=" * 60)
```

- [ ] **Step 2: Save comparison JSON**

```python
comparison = {'v1': V1_METRICS, 'v2': V2_METRICS}
# Add Pi camera results if available
pi_cam_results = Path(DRIVE_BASE) / 'pi_camera_ref' / 'evaluation_results.json'
if pi_cam_results.exists():
    with open(pi_cam_results) as f:
        comparison['v2']['pi_camera_accuracy'] = json.load(f)['overall_accuracy']

with open(f'{DRIVE_BASE}/v1_v2_comparison.json', 'w') as f:
    json.dump(comparison, f, indent=2)
print(f"Saved: {DRIVE_BASE}/v1_v2_comparison.json")
```

---

## Summary of Deliverables

| Artifact | Location | Purpose |
|---|---|---|
| `embedded-project-v2.ipynb` | Kaggle | Full training pipeline (3-class + bg randomization) |
| `model.tflite` | Kaggle → Pi | INT8 quantized 3-class model |
| `pi_camera_ref/` | Pi + `ml-pipeline/` | Real Pi camera reference images |
| `evaluate_reference_set.py` | `ml-pipeline/pi_camera_ref/` | Camera acceptance test script |
| `capture_reference.sh` | Pi | Camera capture helper |
| `pi_daemon.py` | `pi-ai/.../Docker_files/` | 3-class + entropy Unknown (temporal smoothing in Task 7) |
| `v1_v2_comparison.json` | Kaggle working dir | Accuracy comparison for report |

## Decision Gates

**Gate 1 — After Task 3 (quantization):**
- **>90% TFLite test accuracy:** Good. Proceed to Task 5.
- **<90%:** Review dataset quality. Check confusion matrix for systematic errors.

**Gate 2 — After Task 5 (Pi camera reference):**
- **>=85%:** Skip Task 6. Ship model as-is.
- **<85%:** Run Task 6 (few-shot fine-tuning).

**Gate 3 — After Task 6 (fine-tuning, if run):**
- **>=85% camera AND test regression <3pp:** Ship fine-tuned model.
- **Camera OK but test regresses >5pp:** Ship V2 without fine-tuning, accept camera limitations.
- **Both still bad:** Raise confidence thresholds + temporal smoothing to mask uncertainty.
