# Autonomous Drone Planning for Smart-City Emergency Response

**Planning and Approximate Reasoning**

## Group members

- Clara Alessandra Justino
- Mariam H A R Shehadeh

## 1. Contents

| File / folder | Description |
|---|---|
| `domain_a.pddl` | Model A: one recharge action sets the battery to the maximum level (`max-level`), whatever the current level. |
| `domain_b.pddl` | Model B: each recharge action raises the battery by one level (`next-level`); full capacity needs several recharges. |
| `problem-small.pddl` | Instance 1: 1 drone, 5 locations, battery b0-b4. |
| `problem-medium.pddl` | Instance 2: 2 drones, 8 locations, battery b0-b6. |
| `problem-large.pddl` | Instance 3: 3 drones, at least 10 locations. |
| `problem-large-1drone.pddl` | Instance 3 with a single drone (same map and goals), used for the single-drone vs three-drone comparison. |
| `plans/` | Plans returned by Fast Downward (one file per run). |
| `logs/` | Full Fast Downward output for every run. |
| `validation/` | VAL output for every reported plan (see [Section 4](#4-validating-with-val)). |
| `results.csv` | Results table: solved, runtime, plan length, plan cost, expanded states, peak memory, best plan, VAL result. |
| `problem-large-60min-8GB/` | Extra run of A\* + LM-cut on the large instance with a longer limit (see [Section 5](#5-the-folder-problem-large-60min-8gb)). |
| `report.pdf` | Final report. |

### File naming

Files are named `<instance>-<model>-<planner>`, for example `large-A-lamafirst`.

| Part | Values |
|---|---|
| instance | `small` \| `medium` \| `large` \| `large-1drone` |
| model | `A` (`domain_a.pddl`) \| `B` (`domain_b.pddl`) |
| planner | `lamafirst` = `--alias lama-first`<br>`astar` = `--search "astar(lmcut())"`<br>`lama` = `--alias lama` (anytime) |

LAMA anytime writes a new plan each time it finds a cheaper one: `<name>.1.plan`, `<name>.2.plan`, ... The highest number is the best plan of the run.

## 2. Requirements

- [Fast Downward](https://www.fast-downward.org), or its Docker image `aibasel/downward`.
- [VAL](https://github.com/KCL-Planning/VAL), built from source. The commands below assume its `Validate` binary is on the `PATH`.

## 3. Running Fast Downward

All runs use a 5-minute time limit and a 4 GB memory limit. Run the commands from this folder. Replace `domain_a.pddl` with `domain_b.pddl` for Model B, and `problem-small.pddl` with the other problem files.

**LAMA-first:**

```bash
./fast-downward.py --overall-time-limit 5m --overall-memory-limit 4G \
    --plan-file plans/small-A-lamafirst.plan \
    --alias lama-first domain_a.pddl problem-small.pddl
```

**A\* with LM-cut (cost-optimal):**

```bash
./fast-downward.py --overall-time-limit 5m --overall-memory-limit 4G \
    --plan-file plans/small-A-astar.plan \
    domain_a.pddl problem-small.pddl --search "astar(lmcut())"
```

**LAMA anytime (keeps improving the plan until the time limit):**

```bash
./fast-downward.py --overall-time-limit 5m --overall-memory-limit 4G \
    --plan-file plans/large-A-lama.plan \
    --alias lama domain_a.pddl problem-large.pddl
```

**With Docker instead of a local build:**

```bash
docker run --rm -v "$PWD":/work aibasel/downward \
    --overall-time-limit 5m --overall-memory-limit 4G \
    --plan-file /work/plans/small-A-lamafirst.plan \
    --alias lama-first /work/domain_a.pddl /work/problem-small.pddl
```

To keep the full planner output, redirect it to `logs/`, for example:

```bash
... > logs/small-A-lamafirst.log 2>&1
```

## 4. Validating with VAL

Validate each plan with the same domain and problem files given to the planner:

```bash
Validate -v domain_a.pddl problem-large.pddl plans/large-A-lama.9.plan \
    > validation/large-A-lama.9.val
```

The `validation/` folder has both `.txt` and `.val` files. All of them are VAL output, and in every file the result is on the last lines (`Plan valid` and `Final value: <plan cost>`). They were made with two versions of the command:

- `small-*.txt` and `medium-*.txt`: `Validate` without `-v`. They contain only the summary: the plan checked, `Plan valid` and the final cost.
- `large-*.val` and `large-1drone-*.val`: `Validate -v` (verbose). They also contain the type check of every action and a step-by-step replay of the plan.

The extension does not change the content, and both formats give the same verdict and the same plan cost.

## 5. The folder `problem-large-60min-8GB/`

With the required limits (5 min, 4 GB), A\* + LM-cut did not solve `problem-large.pddl` under either model; the reason in both cases was the time limit, not memory. To check whether the instance is just too large for an optimal search or whether a longer limit would help, we ran it again on Model A with a 60-minute time limit and an 8 GB memory limit:

```bash
./fast-downward.py --overall-time-limit 60m --overall-memory-limit 8G \
    domain_a.pddl problem-large.pddl --search "astar(lmcut())" \
    > problem-large-60min-8GB/large-A-astar.log 2>&1
```

`large-A-astar.log` is its output. A\* still stopped at the time limit (3587 s) with no plan, after about 2.4 million expanded states. The f-bound had reached 48, and peak memory was only about 550 MB. So time, not memory, is the bottleneck: LM-cut is costly to compute on each of the many states reachable with three drones.

This is an extra experiment. It is not part of the main results table, which keeps the 5-minute limit required by the assignment.
