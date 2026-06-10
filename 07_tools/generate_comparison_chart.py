import matplotlib.pyplot as plt
import numpy as np

# Metric Data
models = ['YOLOv8m', 'YOLO11m', 'YOLO26m']
metrics = ['mAP50', 'mAP50-95', 'Precision', 'Recall']

# Scores for each model
scores = {
    'YOLOv8m': [0.737, 0.434, 0.661, 0.796],
    'YOLO11m': [0.729, 0.441, 0.715, 0.714],
    'YOLO26m': [0.678, 0.422, 0.671, 0.674]
}

# Modern & Aesthetic Color Palette
colors = {
    'YOLOv8m': '#4f46e5',  # Indigo
    'YOLO11m': '#0d9488',  # Teal
    'YOLO26m': '#e11d48'   # Crimson/Rose
}

x = np.arange(len(metrics))
width = 0.22  # Bar width

fig, ax = plt.subplots(figsize=(12, 7.5), dpi=300)

# Soft background grid lines
ax.set_axisbelow(True)
ax.yaxis.grid(True, color='#f1f5f9', linestyle='-', linewidth=1.5)
ax.xaxis.grid(False)

# Render bars for each model
for i, model in enumerate(models):
    rects = ax.bar(
        x + (i - 1) * width, 
        scores[model], 
        width, 
        label=model, 
        color=colors[model],
        edgecolor='white',
        linewidth=1,
        alpha=0.95
    )
    
    # Add labels above each bar
    for rect in rects:
        height = rect.get_height()
        ax.annotate(
            f'{height:.3f}',
            xy=(rect.get_x() + rect.get_width() / 2, height),
            xytext=(0, 4),  # 4 points vertical offset
            textcoords="offset points",
            ha='center', 
            va='bottom', 
            fontsize=10, 
            fontweight='bold',
            color='#334155'
        )

# Custom Text & Axis Labels
ax.set_title('YOLO Models Comparison - Tea Disease Detection', fontsize=16, fontweight='bold', pad=25, color='#0f172a')
ax.set_xticks(x)
ax.set_xticklabels(metrics, fontsize=12, fontweight='semibold', color='#334155')
ax.set_ylabel('Score / Value', fontsize=12, fontweight='semibold', color='#334155')
ax.set_ylim(0, 0.95)

# Styling Spines (Chart Borders)
for spine in ['top', 'right', 'left']:
    ax.spines[spine].set_visible(False)
ax.spines['bottom'].set_color('#cbd5e1')
ax.spines['bottom'].set_linewidth(1.5)

# Modern Legend
ax.legend(
    loc='upper right', 
    frameon=True, 
    facecolor='white', 
    edgecolor='#e2e8f0', 
    framealpha=0.9, 
    shadow=False, 
    borderpad=1, 
    fontsize=11
)

# Add information text at the bottom of the chart
info_text = (
    "💡 MODEL SUMMARY & ARCHITECTURE:\n"
    "• YOLOv8m : Standard Baseline (Model Size: ~52.0 MB) — Achieved the highest Recall & mAP50.\n"
    "• YOLO11m : Improved Ultralytics Model (Model Size: ~39.0 MB) — Achieved the highest Precision & mAP50-95 (Most Efficient).\n"
    "• YOLO26m : NMS-Free & Edge-Optimized (Model Size: ~42.0 MB) — Specially optimized for edge device deployment."
)
plt.figtext(
    0.12, -0.05, 
    info_text, 
    ha="left", 
    fontsize=10.5, 
    color="#475569", 
    bbox=dict(boxstyle="round,pad=0.8", facecolor="#f8fafc", edgecolor="#e2e8f0", lw=1.2)
)

plt.tight_layout()

# Save to output folder
output_path = '04_outputs/model_comparison_matrix.png'
plt.savefig(output_path, bbox_inches='tight', dpi=300)
print(f"✅ Comparison chart successfully generated & saved to: {output_path}")
