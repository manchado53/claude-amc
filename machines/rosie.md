# Machine: Rosie (MSOE GPU HPC cluster)

This file holds Rosie-only **environment** facts that have no single repo to live in.
Per-project context lives in each project's own CLAUDE.md (auto-loads in that directory).

## Environment
- This machine is **Rosie**, MSOE's SLURM-managed GPU cluster. Docs: https://msoe.dev/#/
- Default conda env for work: `bucks`.
- GPUs are partition-dependent (T4 / V100 / H100). Jupyter-kernel GPU flag is `-G 1` (not `--gres`).

## SLURM
- Submit with `sbatch` (batch) or `srun` (interactive). Modules via `module load` / `module avail`.
- Typical undergrad-research headers:
  ```bash
  #SBATCH --partition=teaching
  #SBATCH --gres=gpu:t4:1
  #SBATCH --cpus-per-gpu=32
  #SBATCH --mem=32G
  #SBATCH --time=14:00:00
  #SBATCH --account=undergrad_research
  ```

## Rule: no spaces in SLURM log paths
`#SBATCH --output` / `--error` break silently on paths with spaces (e.g. `~/REC SYS/`,
`~/DEEP LEARNING/`). Always redirect logs to a flat, space-free dir:
```bash
#SBATCH --output=/home/ad.msoe.edu/manchadoa/<job>_logs/%j.out
#SBATCH --error=/home/ad.msoe.edu/manchadoa/<job>_logs/%j.err
```
Create it first: `mkdir -p ~/<job>_logs`.

## Datasets
- CSC 4611 data at `/data/csc4611/data/` — `fashion_mnist_flattened_{training,testing}.npz`,
  `cifar10_flattened_*.npz`, `cifar100_flattened_*.npz`.
- Large datasets / checkpoints belong in scratch space, not the quota-limited home dir.
