"""Build embedded-project-v2.ipynb from scratch: 3 classes, bg randomization, Pi camera domain mixing."""
import json

def cell(source, cell_type='code'):
    return {
        'cell_type': cell_type,
        'source': source.strip() + '\n',
        'metadata': {},
        'outputs': [],
        'execution_count': None,
    }

cells = []

# ══════════════════════════════════════════════════════════════════════════
# CELL 0: Setup
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
import os, shutil, random, cv2
from pathlib import Path
from collections import defaultdict, Counter
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image
import tensorflow as tf
from tensorflow.keras import layers

DRIVE_BASE = '/kaggle/working'

print(f"TensorFlow: {tf.__version__}")
print(f"GPU: {tf.config.list_physical_devices('GPU')}")
print("Setup complete")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 1: Dataset paths
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
BASE = '/kaggle/input'

PLANTVILLAGE_BASE = f'{BASE}/plantvillage-dataset/color'
PLANTDOC_DIR      = f'{BASE}/plantdoc-dataset'

# Pi camera images — upload your pi_camera_images folder as a Kaggle dataset
# Adjust this path to match your Kaggle dataset name
PI_CAM_DIR = None

for candidate in [
    f'{BASE}/pi-camera-ref/pi_camera_images',
    f'{BASE}/pi-camera-ref',
    f'{BASE}/pi-camera-images/pi_camera_images',
    f'{BASE}/pi-camera-images',
    f'{BASE}/picameraimages/pi_camera_images',
    f'{BASE}/picameraimages',
]:
    if os.path.exists(candidate):
        has_class_dirs = any((Path(candidate)/c).is_dir() for c in ['Healthy', 'Early_Blight', 'Late_Blight'])
        if has_class_dirs:
            PI_CAM_DIR = candidate
            break

print("Dataset paths:")
for label, p in [('PlantVillage color', PLANTVILLAGE_BASE),
                  ('PlantDoc',          PLANTDOC_DIR)]:
    print(f"  [{'OK' if os.path.exists(p) else 'MISSING'}] {label:<20} {p}")

if PI_CAM_DIR:
    print(f"  [OK] Pi Camera             {PI_CAM_DIR}")
    for cls_dir in sorted(Path(PI_CAM_DIR).iterdir()):
        if cls_dir.is_dir():
            n = len([f for f in cls_dir.iterdir() if f.suffix.lower() in ['.jpg','.jpeg','.png']])
            print(f"         {cls_dir.name}: {n} images")
else:
    print("  [MISSING] Pi Camera — will search all /kaggle/input/ ...")
    import subprocess
    result = subprocess.run(['find', '/kaggle/input', '-maxdepth', '3', '-type', 'd'],
                            capture_output=True, text=True)
    print(result.stdout[:2000])
    print("  >>> Set PI_CAM_DIR manually above to the correct path <<<")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 2: Class mapping — 3 classes only
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell(r"""
# 3 classes: Healthy, Early_Blight, Late_Blight.
# Pest dropped: IP102 = generic insect macros, wrong domain entirely.
# Nutrient_Deficiency dropped: Maize NPK = corn leaves, wrong crop morphology.
# Anything the model doesn't recognize -> Unknown via entropy at inference.

OUTPUT_DIR = '/kaggle/working/dataset'
PI_HOLDOUT_DIR = '/kaggle/working/pi_holdout'

CLASSES = ['Early_Blight', 'Healthy', 'Late_Blight']

PLANTVILLAGE_MAP = {
    'Healthy': [
        'Pepper,_bell___healthy',
        'Potato___healthy',
        'Tomato___healthy',
    ],
    'Early_Blight': [
        'Potato___Early_blight',
        'Tomato___Early_blight',
    ],
    'Late_Blight': [
        'Potato___Late_blight',
        'Tomato___Late_blight',
    ],
}

MAX_PER_CLASS = 2500

available = os.listdir(PLANTVILLAGE_BASE)
print(f"PlantVillage color folders: {len(available)}")
print("\nVerifying PlantVillage folders:")
for cls, folders in PLANTVILLAGE_MAP.items():
    for f in folders:
        print(f"  [{'OK' if f in available else 'MISSING'}] {cls:<14} {f}")

# --- PlantDoc: field images, keyword-matched ---
def find_image_folders(root):
    found = []
    for dirpath, _, filenames in os.walk(root):
        if any(f.lower().endswith(('.jpg', '.jpeg', '.png')) for f in filenames):
            found.append((os.path.basename(dirpath), dirpath))
    return found

DISEASE_WORDS = ['blight', 'spot', 'mold', 'mould', 'virus', 'rust', 'mildew',
                 'rot', 'bacterial', 'mosaic', 'curl', 'scab', 'deficien']

PLANTDOC_MAP = {'Healthy': [], 'Early_Blight': [], 'Late_Blight': []}
for name, path in find_image_folders(PLANTDOC_DIR):
    low = name.lower()
    if 'blight' in low and 'early' in low:
        PLANTDOC_MAP['Early_Blight'].append(path)
    elif 'blight' in low and 'late' in low:
        PLANTDOC_MAP['Late_Blight'].append(path)
    elif (any(c in low for c in ['tomato', 'potato', 'pepper', 'bell'])
          and not any(w in low for w in DISEASE_WORDS)):
        PLANTDOC_MAP['Healthy'].append(path)

print("\nPlantDoc matched folders (field images):")
for cls, paths in PLANTDOC_MAP.items():
    names = [os.path.basename(p) for p in paths]
    print(f"  {cls:<14} {len(paths)}: {names}")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 3: Background randomization + dataset build (PlantVillage + PlantDoc)
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell(r"""
import urllib.request, tarfile

DTD_DIR = '/kaggle/working/dtd_textures'
if not os.path.exists(DTD_DIR):
    print("Downloading DTD textures...")
    urllib.request.urlretrieve(
        'https://www.robots.ox.ac.uk/~vgg/data/dtd/download/dtd-r1.0.1.tar.gz',
        '/tmp/dtd.tar.gz')
    with tarfile.open('/tmp/dtd.tar.gz') as tar:
        tar.extractall('/kaggle/working/')
    os.rename('/kaggle/working/dtd/images', DTD_DIR)

bg_paths = list(Path(DTD_DIR).rglob('*.jpg'))
print(f"Background textures: {len(bg_paths)}")


def segment_leaf(img_pil, threshold=220):
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
    return 'plantvillage' in str(img_path).lower()


def list_images(folder):
    p = Path(folder)
    return (list(p.glob('*.jpg')) + list(p.glob('*.JPG'))
            + list(p.glob('*.jpeg')) + list(p.glob('*.png')))


# ---- Gather images per class ----
for cls in CLASSES:
    os.makedirs(Path(OUTPUT_DIR) / cls, exist_ok=True)

class_images = {cls: [] for cls in CLASSES}

for cls, folders in PLANTVILLAGE_MAP.items():
    for folder in folders:
        src = Path(PLANTVILLAGE_BASE) / folder
        if src.exists():
            class_images[cls].extend(list_images(src))

for cls, paths in PLANTDOC_MAP.items():
    for path in paths:
        class_images[cls].extend(list_images(path))

# ---- Copy with background randomization on lab images ----
ORIG_KEEP_RATIO = 0.3

print(f"\n=== Copying (cap {MAX_PER_CLASS}/class, bg-swap lab images) ===")
copied = {}

for cls in CLASSES:
    imgs = class_images[cls]
    random.shuffle(imgs)
    imgs = imgs[:MAX_PER_CLASS]

    lab_imgs = [p for p in imgs if is_plantvillage(p)]
    field_imgs = [p for p in imgs if not is_plantvillage(p)]
    n_lab_orig = int(len(lab_imgs) * ORIG_KEEP_RATIO)

    n = 0
    for img_path in field_imgs:
        dst = Path(OUTPUT_DIR) / cls / f"{n:05d}_field_{img_path.name}"
        if not dst.exists():
            shutil.copy(img_path, dst)
        n += 1

    for i, img_path in enumerate(lab_imgs):
        img = Image.open(img_path).convert('RGB')
        if i < n_lab_orig:
            out = img.resize((256, 256))
        else:
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
    print(f"  {cls:<22} {n:>5}  (field:{len(field_imgs)} lab-orig:{n_lab_orig} lab-swap:{lab_swapped})  {bar}")

total = sum(copied.values())
print(f"\nPlantVillage + PlantDoc total: {total} images")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 4: Pi camera augmentation + mixing into training pool
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell(r"""
# Pi camera images bridge the domain gap between lab/field datasets and
# real exhibition conditions. Heavy augmentation of ~30 originals creates
# enough Pi-domain examples that the 80/20 train/val split naturally
# includes them in BOTH sets — so val_accuracy tracks real-camera
# generalization every epoch, and checkpoint selection favors it.

HOLDOUT_PER_CLASS = 2
AUGMENTATIONS_PER_IMAGE = 50

def augment_pi_image(img_np, target_size=256):
    h, w = img_np.shape[:2]

    # Random crop (70-100% of image)
    crop_scale = random.uniform(0.7, 1.0)
    crop_h, crop_w = int(h * crop_scale), int(w * crop_scale)
    y0 = random.randint(0, h - crop_h)
    x0 = random.randint(0, w - crop_w)
    img = img_np[y0:y0+crop_h, x0:x0+crop_w]

    img = cv2.resize(img, (target_size, target_size))

    # Random rotation
    angle = random.uniform(-30, 30)
    M = cv2.getRotationMatrix2D((target_size//2, target_size//2), angle, 1.0)
    img = cv2.warpAffine(img, M, (target_size, target_size),
                         borderMode=cv2.BORDER_REFLECT_101)

    if random.random() > 0.5:
        img = cv2.flip(img, 1)

    if random.random() > 0.3:
        img = cv2.flip(img, 0)

    # Brightness + contrast
    alpha = random.uniform(0.7, 1.3)
    beta = random.randint(-30, 30)
    img = cv2.convertScaleAbs(img, alpha=alpha, beta=beta)

    # Hue/saturation shift
    if random.random() > 0.3:
        hsv = cv2.cvtColor(img, cv2.COLOR_RGB2HSV).astype(np.int16)
        hsv[:,:,0] = (hsv[:,:,0] + random.randint(-10, 10)) % 180
        hsv[:,:,1] = np.clip(hsv[:,:,1] + random.randint(-30, 30), 0, 255)
        img = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2RGB)

    # Gaussian blur
    if random.random() > 0.5:
        ksize = random.choice([3, 5])
        img = cv2.GaussianBlur(img, (ksize, ksize), 0)

    # Gaussian noise
    if random.random() > 0.6:
        noise = np.random.normal(0, random.uniform(5, 15), img.shape).astype(np.int16)
        img = np.clip(img.astype(np.int16) + noise, 0, 255).astype(np.uint8)

    # Perspective warp
    if random.random() > 0.5:
        pts1 = np.float32([[0,0], [target_size,0], [0,target_size], [target_size,target_size]])
        jitter = target_size * 0.05
        pts2 = pts1 + np.random.uniform(-jitter, jitter, pts1.shape).astype(np.float32)
        M_persp = cv2.getPerspectiveTransform(pts1, pts2)
        img = cv2.warpPerspective(img, M_persp, (target_size, target_size),
                                   borderMode=cv2.BORDER_REFLECT_101)

    return img


if PI_CAM_DIR is None:
    print("WARNING: Pi camera images not found. Skipping Pi domain mixing.")
    print("Upload your pi_camera_images folder as a Kaggle dataset and adjust PI_CAM_DIR in cell 1.")
    pi_stats = {}
else:
    for cls in CLASSES:
        os.makedirs(Path(PI_HOLDOUT_DIR) / cls, exist_ok=True)

    pi_stats = {}

    for cls in CLASSES:
        cls_dir = Path(PI_CAM_DIR) / cls
        if not cls_dir.exists():
            print(f"  WARNING: {cls_dir} not found, skipping")
            continue

        imgs = sorted(list_images(cls_dir))
        random.shuffle(imgs)

        if len(imgs) == 0:
            print(f"  WARNING: {cls} has 0 Pi camera images")
            continue

        holdout = imgs[:HOLDOUT_PER_CLASS]
        train_imgs = imgs[HOLDOUT_PER_CLASS:]

        for img_path in holdout:
            dst = Path(PI_HOLDOUT_DIR) / cls / img_path.name
            shutil.copy(img_path, dst)

        # Copy originals into training pool
        n_orig = 0
        for img_path in train_imgs:
            dst = Path(OUTPUT_DIR) / cls / f"picam_orig_{img_path.name}"
            img = Image.open(img_path).convert('RGB').resize((256, 256))
            img.save(dst, quality=90)
            n_orig += 1

        # Generate augmented versions
        n_aug = 0
        for img_path in train_imgs:
            img_pil = Image.open(img_path).convert('RGB')
            img_np = np.array(img_pil)

            for aug_i in range(AUGMENTATIONS_PER_IMAGE):
                aug = augment_pi_image(img_np, target_size=256)
                dst = Path(OUTPUT_DIR) / cls / f"picam_aug_{img_path.stem}_{aug_i:03d}.jpg"
                Image.fromarray(aug).save(dst, quality=90)
                n_aug += 1

        pi_stats[cls] = {
            'originals': len(imgs),
            'holdout': len(holdout),
            'train_orig': n_orig,
            'augmented': n_aug,
            'total_added': n_orig + n_aug,
        }

        print(f"  {cls:<16}: {len(imgs)} originals -> "
              f"{len(holdout)} holdout + {n_orig} train-orig + {n_aug} augmented "
              f"= {n_orig + n_aug} added to training pool")

    print(f"\n=== Final dataset (PlantVillage + PlantDoc + Pi Camera) ===")
    for cls in CLASSES:
        cls_path = Path(OUTPUT_DIR) / cls
        n = len(list(cls_path.rglob("*")))
        print(f"  {cls:<22} {n:>5} images")

    holdout_total = sum(len(list((Path(PI_HOLDOUT_DIR)/c).rglob("*")))
                        for c in CLASSES if (Path(PI_HOLDOUT_DIR)/c).exists())
    print(f"\nPi camera holdout: {holdout_total} images (pure test, never seen during training)")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 5: Visualize Pi camera augmentation samples
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell(r"""
if PI_CAM_DIR is not None:
    fig, axes = plt.subplots(3, 6, figsize=(15, 8))
    fig.suptitle('Pi Camera: Original (col 1) vs Augmented (cols 2-6)', fontsize=13, y=1.01)

    for row, cls in enumerate(CLASSES):
        cls_dir = Path(PI_CAM_DIR) / cls
        if not cls_dir.exists():
            continue
        sample = sorted(list_images(cls_dir))[0]
        img_np = np.array(Image.open(sample).convert('RGB'))

        axes[row][0].imshow(cv2.resize(img_np, (256, 256)))
        axes[row][0].set_title(f'{cls}\n(original)', fontsize=8)
        axes[row][0].axis('off')

        for col in range(1, 6):
            aug = augment_pi_image(img_np, target_size=256)
            axes[row][col].imshow(aug)
            axes[row][col].set_title(f'aug {col}', fontsize=8)
            axes[row][col].axis('off')

    plt.tight_layout()
    plt.savefig(f'{DRIVE_BASE}/pi_camera_augmentation.png', dpi=120, bbox_inches='tight')
    plt.show()
else:
    print("Pi camera images not available — skipping visualization")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 6: Class balance bar chart
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell(r"""
classes = []
counts_base = []
counts_picam = []

for cls in sorted(os.listdir(OUTPUT_DIR)):
    path = Path(OUTPUT_DIR) / cls
    if not path.is_dir():
        continue
    all_imgs = list(path.rglob("*"))
    pi_imgs = [p for p in all_imgs if 'picam' in p.name]
    classes.append(cls.replace('_', '\n'))
    counts_base.append(len(all_imgs) - len(pi_imgs))
    counts_picam.append(len(pi_imgs))

fig, ax = plt.subplots(figsize=(10, 4))
x = range(len(classes))
bars1 = ax.bar(x, counts_base, color='#2d9e5f', edgecolor='#0a2e1a',
               linewidth=0.5, label='PlantVillage + PlantDoc')
bars2 = ax.bar(x, counts_picam, bottom=counts_base, color='#e8a020',
               edgecolor='#0a2e1a', linewidth=0.5, label='Pi Camera (augmented)')
ax.set_xticks(x)
ax.set_xticklabels(classes)
ax.set_title('Dataset class balance (3 classes + Pi camera domain)', fontsize=13, pad=12)
ax.set_ylabel('Images')
ax.legend()
total_each = [b + p for b, p in zip(counts_base, counts_picam)]
if total_each:
    ax.set_ylim(0, max(total_each) * 1.15)
for i, (b, p) in enumerate(zip(counts_base, counts_picam)):
    ax.text(i, b + p + 30, str(b + p), ha='center', va='bottom', fontsize=10)
plt.tight_layout()
plt.savefig(f'{DRIVE_BASE}/class_balance.png', dpi=120)
plt.show()
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 7: Sample images
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
n_classes = len([d for d in os.listdir(OUTPUT_DIR) if (Path(OUTPUT_DIR)/d).is_dir()])
fig, axes = plt.subplots(n_classes, 4, figsize=(12, 3 * n_classes))
fig.suptitle('Samples: field / lab-original / lab-bg-swapped / pi-camera', fontsize=11, y=1.01)

for row, cls in enumerate(sorted(os.listdir(OUTPUT_DIR))):
    cls_path = Path(OUTPUT_DIR) / cls
    if not cls_path.is_dir():
        continue
    all_imgs = list(cls_path.iterdir())

    groups = [
        ('field',    [p for p in all_imgs if 'field' in p.name]),
        ('lab-orig', [p for p in all_imgs if 'lab' in p.name][:10]),
        ('lab-swap', [p for p in all_imgs if 'lab' in p.name][10:]),
        ('pi-cam',   [p for p in all_imgs if 'picam' in p.name]),
    ]

    for col, (label, group) in enumerate(groups):
        if group:
            img = Image.open(random.choice(group)).resize((224, 224))
            axes[row][col].imshow(img)
        if row == 0:
            axes[row][col].set_title(label, fontsize=9)
        axes[row][col].axis('off')
    axes[row][0].set_ylabel(cls.replace('_', ' '), fontsize=9, rotation=0,
                             labelpad=60, va='center')

plt.tight_layout()
plt.savefig(f'{DRIVE_BASE}/sample_images.png', dpi=100, bbox_inches='tight')
plt.show()
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 8: Data loading + splits
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
IMG_SIZE    = 224
BATCH_SIZE  = 32
SEED        = 42
NUM_CLASSES = 3

train_ds = tf.keras.utils.image_dataset_from_directory(
    OUTPUT_DIR,
    validation_split=0.2,
    subset="training",
    seed=SEED,
    image_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    label_mode='categorical',
)

val_test_pool = tf.keras.utils.image_dataset_from_directory(
    OUTPUT_DIR,
    validation_split=0.2,
    subset="validation",
    seed=SEED,
    image_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    label_mode='categorical',
)

val_batches = len(val_test_pool) // 2
val_ds  = val_test_pool.take(val_batches)
test_ds = val_test_pool.skip(val_batches)

print(f"Train: {len(train_ds)} batches")
print(f"Val:   {len(val_ds)} batches")
print(f"Test:  {len(test_ds)} batches")

AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.cache().shuffle(1000).prefetch(AUTOTUNE)
val_ds   = val_ds.cache().prefetch(AUTOTUNE)
test_ds  = test_ds.cache().prefetch(AUTOTUNE)
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 9: Augmentation
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal_and_vertical"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
    layers.RandomBrightness(0.25, value_range=(0, 255)),
    layers.RandomContrast(0.2),
    layers.RandomTranslation(0.1, 0.1),
], name='augmentation')

sample_images, _ = next(iter(train_ds.take(1)))
fig, axes = plt.subplots(2, 5, figsize=(12, 5))
fig.suptitle('Original (top) vs TF Augmented (bottom)', fontsize=11)
for i in range(5):
    img = sample_images[i].numpy().astype('uint8')
    aug = augmentation(tf.expand_dims(sample_images[i], 0), training=True)
    aug = aug[0].numpy().clip(0, 255).astype('uint8')
    axes[0][i].imshow(img);  axes[0][i].axis('off')
    axes[1][i].imshow(aug);  axes[1][i].axis('off')
plt.tight_layout()
plt.savefig(f'{DRIVE_BASE}/augmentation_preview.png', dpi=100)
plt.show()
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 10: Model
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
from tensorflow.keras import Model
from tensorflow.keras.applications import MobileNetV2

base = MobileNetV2(
    input_shape=(IMG_SIZE, IMG_SIZE, 3),
    include_top=False,
    weights='imagenet',
)

base.trainable = True
for layer in base.layers[:100]:
    layer.trainable = False

frozen  = sum(1 for l in base.layers if not l.trainable)
unfrozen = sum(1 for l in base.layers if l.trainable)
print(f"Base model: {frozen} layers frozen, {unfrozen} layers trainable")

inputs = tf.keras.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
x = augmentation(inputs, training=True)
x = tf.keras.applications.mobilenet_v2.preprocess_input(x)
x = base(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.4)(x)
outputs = layers.Dense(NUM_CLASSES, activation='softmax')(x)

model = Model(inputs, outputs, name='irrigation_mobilenetv2')
model.summary(show_trainable=True)
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 11: Class weights
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
from sklearn.utils.class_weight import compute_class_weight

CLASS_NAMES = sorted(os.listdir(OUTPUT_DIR))
CLASS_NAMES = [c for c in CLASS_NAMES if (Path(OUTPUT_DIR)/c).is_dir()]
print(f"Classes: {CLASS_NAMES}")

all_labels = []
for _, labels in train_ds.unbatch():
    all_labels.append(np.argmax(labels.numpy()))

all_labels = np.array(all_labels)
unique_classes = np.unique(all_labels)

weights = compute_class_weight(
    class_weight='balanced',
    classes=unique_classes,
    y=all_labels,
)

class_weight_dict = dict(zip(unique_classes, weights))
print("Class weights:")
for idx, name in enumerate(CLASS_NAMES):
    print(f"  {name:<22}: {class_weight_dict[idx]:.3f}")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 12: Training
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
from tensorflow.keras.callbacks import (
    EarlyStopping, ModelCheckpoint, ReduceLROnPlateau
)

CHECKPOINT_PATH = f'{DRIVE_BASE}/best_model.keras'

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),
    loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1),
    metrics=['accuracy'],
)

callbacks = [
    EarlyStopping(
        monitor='val_accuracy',
        patience=5,
        restore_best_weights=True,
        verbose=1,
    ),
    ModelCheckpoint(
        filepath=CHECKPOINT_PATH,
        monitor='val_accuracy',
        save_best_only=True,
        verbose=1,
    ),
    ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.5,
        patience=2,
        min_lr=1e-6,
        verbose=1,
    ),
]

print("Starting training...")
print(f"Best model will be saved to: {CHECKPOINT_PATH}")

history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=25,
    callbacks=callbacks,
    class_weight=class_weight_dict,
    verbose=1,
)
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 13: Training curves
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

ax1.plot(history.history['accuracy'],     label='Train', color='#2d9e5f', linewidth=2)
ax1.plot(history.history['val_accuracy'], label='Val',   color='#0a2e1a', linewidth=2, linestyle='--')
ax1.set_title('Accuracy over epochs')
ax1.set_xlabel('Epoch'); ax1.set_ylabel('Accuracy')
ax1.legend(); ax1.grid(alpha=0.3)
ax1.set_ylim(0, 1)

ax2.plot(history.history['loss'],     label='Train', color='#e8a020', linewidth=2)
ax2.plot(history.history['val_loss'], label='Val',   color='#d94040', linewidth=2, linestyle='--')
ax2.set_title('Loss over epochs')
ax2.set_xlabel('Epoch'); ax2.set_ylabel('Loss')
ax2.legend(); ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig(f'{DRIVE_BASE}/training_curves.png', dpi=120)
plt.show()

final_acc = history.history['val_accuracy'][-1]
best_acc  = max(history.history['val_accuracy'])
print(f"Final val accuracy: {final_acc:.3f}")
print(f"Best  val accuracy: {best_acc:.3f}")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 14: Confusion matrix
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
from sklearn.metrics import confusion_matrix, classification_report
import seaborn as sns

y_true, y_pred = [], []
for images, labels in test_ds:
    preds = model.predict(images, verbose=0)
    y_true.extend(np.argmax(labels.numpy(), axis=1))
    y_pred.extend(np.argmax(preds, axis=1))

y_true = np.array(y_true)
y_pred = np.array(y_pred)

cm = confusion_matrix(y_true, y_pred)
cm_pct = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]

fig, ax = plt.subplots(figsize=(7, 5))
sns.heatmap(cm_pct, annot=True, fmt='.2f', cmap='Greens',
            xticklabels=CLASS_NAMES, yticklabels=CLASS_NAMES,
            ax=ax, linewidths=0.5)
ax.set_title('Confusion matrix (row-normalized)', fontsize=12, pad=12)
ax.set_xlabel('Predicted'); ax.set_ylabel('Actual')
plt.xticks(rotation=30, ha='right', fontsize=9)
plt.yticks(rotation=0, fontsize=9)
plt.tight_layout()
plt.savefig(f'{DRIVE_BASE}/confusion_matrix.png', dpi=120)
plt.show()

print("\\nClassification report:")
print(classification_report(y_true, y_pred, target_names=CLASS_NAMES, digits=3))
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 15: Pi camera holdout evaluation
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell(r"""
if os.path.exists(PI_HOLDOUT_DIR) and any(Path(PI_HOLDOUT_DIR).iterdir()):
    print("=== Pi Camera Holdout Evaluation (never-seen originals) ===\n")

    pi_correct, pi_total = 0, 0
    pi_results = {}

    for cls_dir in sorted(Path(PI_HOLDOUT_DIR).iterdir()):
        if not cls_dir.is_dir():
            continue
        cls = cls_dir.name
        pi_results[cls] = {'correct': 0, 'total': 0}

        for img_path in sorted(cls_dir.glob('*')):
            if img_path.suffix.lower() not in ['.jpg', '.jpeg', '.png']:
                continue
            img = tf.keras.utils.load_img(img_path, target_size=(IMG_SIZE, IMG_SIZE))
            arr = tf.keras.utils.img_to_array(img)
            pred = model.predict(np.expand_dims(arr, 0), verbose=0)[0]

            pred_idx = int(np.argmax(pred))
            pred_cls = CLASS_NAMES[pred_idx]
            conf = float(pred[pred_idx])

            p = np.clip(pred, 1e-9, 1.0)
            entropy = float(-np.sum(p * np.log(p)) / np.log(len(CLASS_NAMES)))

            correct = (pred_cls == cls)
            pi_results[cls]['total'] += 1
            pi_total += 1
            if correct:
                pi_results[cls]['correct'] += 1
                pi_correct += 1

            tag = "OK" if correct else "WRONG"
            print(f"  [{tag}] {cls}/{img_path.name}: pred={pred_cls} "
                  f"(conf={conf:.1%}, entropy={entropy:.3f})")

    pi_acc = pi_correct / pi_total if pi_total > 0 else 0
    print(f"\nPi Camera Holdout: {pi_correct}/{pi_total} = {pi_acc:.0%}")
    for cls in CLASS_NAMES:
        r = pi_results.get(cls, {'correct': 0, 'total': 0})
        if r['total'] > 0:
            print(f"  {cls:<16}: {r['correct']}/{r['total']}")

    verdict = "PASS" if pi_acc >= 0.85 else "NEEDS ATTENTION"
    print(f"\n{verdict} (target: >=85%)")
else:
    print("No Pi camera holdout set found — skipping")
    pi_acc = None
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 16: Entropy calibration
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
import json

entropies, correct = [], []
for images, labels in test_ds:
    preds = model.predict(images, verbose=0)
    for p, lbl in zip(preds, labels.numpy()):
        p   = np.clip(p, 1e-9, 1.0)
        ent = -np.sum(p * np.log(p)) / np.log(len(CLASS_NAMES))
        entropies.append(ent)
        correct.append(int(np.argmax(p) == np.argmax(lbl)))

entropies = np.array(entropies)
correct   = np.array(correct)
ent_correct = entropies[correct == 1]
ent_wrong   = entropies[correct == 0]

ENTROPY_THRESHOLD = float(np.percentile(ent_correct, 95)) if len(ent_correct) else 0.55

fig, ax = plt.subplots(figsize=(8, 4))
ax.hist(ent_correct, bins=30, alpha=0.7, label='correct', color='#2d9e5f')
ax.hist(ent_wrong,   bins=30, alpha=0.7, label='wrong',   color='#d94040')
ax.axvline(ENTROPY_THRESHOLD, color='k', linestyle='--',
           label=f'threshold {ENTROPY_THRESHOLD:.3f}')
ax.set_title('Prediction entropy: correct vs wrong')
ax.set_xlabel('Normalized entropy'); ax.set_ylabel('Count'); ax.legend()
plt.tight_layout()
plt.savefig(f'{DRIVE_BASE}/entropy_calibration.png', dpi=120)
plt.show()

flagged = (ent_wrong > ENTROPY_THRESHOLD).mean() * 100 if len(ent_wrong) else 0
print(f"ENTROPY_THRESHOLD = {ENTROPY_THRESHOLD:.4f}")
print(f"  correct preds: mean entropy {ent_correct.mean():.3f}")
if len(ent_wrong):
    print(f"  wrong   preds: mean entropy {ent_wrong.mean():.3f}  "
          f"({flagged:.0f}% of wrong preds would be flagged Unknown)")
else:
    print("  no wrong predictions on test set")

with open(f'{DRIVE_BASE}/entropy_threshold.json', 'w') as f:
    json.dump({'entropy_threshold': ENTROPY_THRESHOLD, 'num_classes': len(CLASS_NAMES)}, f)
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 17: Save artifacts
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
import json

with open(f'{DRIVE_BASE}/class_names.json', 'w') as f:
    json.dump(CLASS_NAMES, f)

with open(f'{DRIVE_BASE}/training_history.json', 'w') as f:
    json.dump({k: [float(v) for v in vals]
               for k, vals in history.history.items()}, f)

model.save(f'{DRIVE_BASE}/final_model.keras')

print("Saved:")
print(f"  {DRIVE_BASE}/best_model.keras")
print(f"  {DRIVE_BASE}/final_model.keras")
print(f"  {DRIVE_BASE}/class_names.json")
print(f"  {DRIVE_BASE}/training_history.json")
print(f"  {DRIVE_BASE}/entropy_threshold.json")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 18: Install ai-edge-litert
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("pip install ai-edge-litert"))

# ══════════════════════════════════════════════════════════════════════════
# CELL 19: TFLite setup
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
import gc
import os
import json
import numpy as np
import tensorflow as tf
from ai_edge_litert.interpreter import Interpreter

DRIVE_BASE  = '/kaggle/working'
OUTPUT_DIR  = '/kaggle/working/dataset'
MODEL_PATH  = f'{DRIVE_BASE}/best_model.keras'
TFLITE_PATH = f'{DRIVE_BASE}/irrigation_int8.tflite'
IMG_SIZE    = 224
BATCH_SIZE  = 32
SEED        = 42
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 20: Keras baseline accuracy
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
val_test_pool = tf.keras.utils.image_dataset_from_directory(
    OUTPUT_DIR,
    validation_split=0.2,
    subset='validation',
    seed=SEED,
    image_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    label_mode='categorical',
)

val_batches = len(val_test_pool) // 2
test_ds  = val_test_pool.skip(val_batches).prefetch(tf.data.AUTOTUNE)
calib_ds = val_test_pool.take(val_batches).prefetch(tf.data.AUTOTUNE)

model = tf.keras.models.load_model(MODEL_PATH)
_, keras_acc = model.evaluate(test_ds, verbose=1)
print(f"\\nKeras float32 accuracy: {keras_acc:.4f}  ({keras_acc*100:.2f}%)")

del model
gc.collect()
tf.keras.backend.clear_session()
print("Keras model freed from memory")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 21: INT8 quantization
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
CALIB_BATCHES = 20

def representative_dataset():
    count = 0
    for images, _ in calib_ds.take(CALIB_BATCHES):
        for img in images:
            yield [tf.expand_dims(img, axis=0)]
            count += 1
    print(f"Calibration samples: {count}")

model = tf.keras.models.load_model(MODEL_PATH)

converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations             = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset    = representative_dataset
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type      = tf.int8
converter.inference_output_type     = tf.int8

tflite_model = converter.convert()

del model
gc.collect()
tf.keras.backend.clear_session()

with open(TFLITE_PATH, 'wb') as f:
    f.write(tflite_model)

size_mb = os.path.getsize(TFLITE_PATH) / 1e6
print(f"Saved : {TFLITE_PATH}")
print(f"Size  : {size_mb:.2f} MB  {'PASS (<4 MB)' if size_mb < 4 else 'FAIL (>=4 MB)'}")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 22: TFLite accuracy check
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
interpreter = Interpreter(model_path=TFLITE_PATH)
interpreter.allocate_tensors()

inp  = interpreter.get_input_details()[0]
out  = interpreter.get_output_details()[0]
in_scale,  in_zp  = inp['quantization']
out_scale, out_zp = out['quantization']

print(f"Input  -- scale={in_scale:.6f}  zero_point={in_zp}")
print(f"Output -- scale={out_scale:.6f}  zero_point={out_zp}")

correct, total = 0, 0

for images, labels in test_ds:
    for img, label in zip(images.numpy(), labels.numpy()):
        img_int8 = np.round(img / in_scale + in_zp).clip(-128, 127).astype(np.int8)
        interpreter.set_tensor(inp['index'], img_int8[np.newaxis])
        interpreter.invoke()
        logits = (interpreter.get_tensor(out['index']).astype(np.float32) - out_zp) * out_scale
        correct += int(np.argmax(logits) == np.argmax(label))
        total   += 1

tflite_acc = correct / total
drop       = keras_acc - tflite_acc

print(f"\\nKeras  accuracy : {keras_acc:.4f}  ({keras_acc*100:.2f}%)")
print(f"TFLite accuracy : {tflite_acc:.4f}  ({tflite_acc*100:.2f}%)")
print(f"Accuracy drop   : {drop*100:.2f} pp  {'PASS (<2pp)' if drop < 0.02 else 'FAIL (>=2pp)'}")
"""))

# ══════════════════════════════════════════════════════════════════════════
# CELL 23: Save TFLite + summary
# ══════════════════════════════════════════════════════════════════════════
cells.append(cell("""
with open(f'{DRIVE_BASE}/model.tflite', 'wb') as f:
    f.write(tflite_model)

summary = {
    'keras_accuracy' : float(keras_acc),
    'tflite_accuracy': float(tflite_acc),
    'accuracy_drop'  : float(drop),
    'model_size_mb'  : float(size_mb),
    'in_scale'       : float(in_scale),
    'in_zero_point'  : int(in_zp),
    'out_scale'      : float(out_scale),
    'out_zero_point' : int(out_zp),
    'img_size'       : IMG_SIZE,
    'num_classes'    : 3,
}
with open(f'{DRIVE_BASE}/tflite_summary.json', 'w') as f:
    json.dump(summary, f, indent=2)

print(f"Model saved   -> {DRIVE_BASE}/model.tflite")
print(f"Summary saved -> {DRIVE_BASE}/tflite_summary.json")
"""))

# ══════════════════════════════════════════════════════════════════════════
# Assemble notebook
# ══════════════════════════════════════════════════════════════════════════
nb = {
    'nbformat': 4,
    'nbformat_minor': 5,
    'metadata': {
        'kernelspec': {
            'name': 'python3',
            'display_name': 'Python 3',
            'language': 'python',
        },
        'language_info': {
            'name': 'python',
            'version': '3.12.12',
            'mimetype': 'text/x-python',
            'codemirror_mode': {'name': 'ipython', 'version': 3},
            'pygments_lexer': 'ipython3',
            'nbconvert_exporter': 'python',
            'file_extension': '.py',
        },
        'accelerator': 'GPU',
        'kaggle': {
            'accelerator': 'gpu',
            'isGpuEnabled': True,
            'isInternetEnabled': True,
        },
    },
    'cells': cells,
}

OUTPUT = 'embedded-project-v2.ipynb'
with open(OUTPUT, 'w', encoding='utf-8') as f:
    json.dump(nb, f, indent=1, ensure_ascii=False)

print(f"\nSaved {OUTPUT}: {len(cells)} cells")
for i, c in enumerate(cells):
    first = c['source'].strip().split('\n')[0][:80]
    print(f"  cell {i:2d}: {first}")
