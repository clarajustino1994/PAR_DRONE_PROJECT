# Autonomous Drone Planning for Smart-City Emergency Response

Planning and Approximate Reasoning (PAR): final project.

**Group members**

- Clara Alessandra Justino Limaco
- Mariam H A R Shehadeh

## 1. Contents

| File / folder | Description |
|---|---|
| `domain-A.pddl` | Model A: one recharge action sets the battery to the maximum level (`max-level`), whatever the current level. |
| `domain-B.pddl` | Model B: each recharge action raises the battery by one level (`next-level`); full capacity needs several recharges. |
| `problem-small.pddl` | Instance 1: 1 drone, 5 locations, battery b0–b4. |
| `problem-medium.pddl` | Instance 2: 2 drones, 8 locations, battery b0–b6. |
| `problem-large.pddl` | Instance 3: 3 drones, 16 locations, battery b0–b5. |
| `problem-large-1drone.pddl` | Instance 3 with a single drone (same map and goals). |
| `plans/` | Every plan returned by Fast Downward (see [Section 7](#7-the-folder-plans-all-generated-plans)). |
| `logs/` | Full Fast Downward output of every run. |
| `validation/` | VAL output (`Validate -v`) for every plan in `plans/`. |
| `results.csv` | Results of every run (see [Section 6](#6-the-file-resultscsv)). |
| `problem-large-60min-8GB/` | Extra A* + LM-cut run on the large instance with a longer limit (see [Section 5](#5-the-folder-problem-large-60min-8gb)). |
| `report.pdf` | Final report. |

File naming: `<instance>-<model>-<planner>`, for example `large-A-lamafirst`.

| Part | Values |
|---|---|
| instance | `small` \| `medium` \| `large` \| `large-1drone` |
| model | `A` (`domain-A.pddl`) \| `B` (`domain-B.pddl`) |
| planner | `lamafirst` = `--alias lama-first`<br>`astar` = `--search "astar(lmcut())"`<br>`lama` = `--alias lama` (anytime LAMA) |

Anytime LAMA writes a new plan each time it finds a cheaper one:
`plans/<name>.plan.1`, `plans/<name>.plan.2`, … The highest number is the best
plan of the run. Its VAL output is `validation/<name>.<N>.val`.
A run with no plan file did not find a plan within the limits; the reason is
at the end of its log in `logs/`.

## 2. Requirements

- [Fast Downward](https://www.fast-downward.org), or its Docker image
  `aibasel/downward`. We used the Docker image: the Fast Downward driver can
  only enforce `--overall-memory-limit` on Linux, so on macOS a local build
  stops with "Setting memory limits is not supported on your platform".
- [VAL](https://github.com/KCL-Planning/VAL), built from source. The commands
  below assume its `Validate` binary is on the `PATH`.

## 3. Running Fast Downward

All runs use a 5-minute time limit and a 4 GB memory limit and are run from
this folder. Replace `domain-A.pddl` with `domain-B.pddl` for Model B, and
`problem-small.pddl` with the other problem files. With a local Linux build,
replace `docker run --rm -v "$PWD":/work -w /work aibasel/downward` by
`./fast-downward.py` and drop the `/work/` prefix of `--plan-file`.

**LAMA-first:**

```sh
docker run --rm -v "$PWD":/work -w /work aibasel/downward \
    --overall-time-limit 5m --overall-memory-limit 4G \
    --plan-file /work/plans/small-A-lamafirst.plan \
    --alias lama-first domain-A.pddl problem-small.pddl \
    > logs/small-A-lamafirst.log 2>&1
```

**A\* with LM-cut (cost-optimal):**

```sh
docker run --rm -v "$PWD":/work -w /work aibasel/downward \
    --overall-time-limit 5m --overall-memory-limit 4G \
    --plan-file /work/plans/small-A-astar.plan \
    domain-A.pddl problem-small.pddl --search "astar(lmcut())" \
    > logs/small-A-astar.log 2>&1
```

**LAMA anytime (keeps improving the plan until the time limit):**

```sh
docker run --rm -v "$PWD":/work -w /work aibasel/downward \
    --overall-time-limit 5m --overall-memory-limit 4G \
    --plan-file /work/plans/large-A-lama.plan \
    --alias lama domain-A.pddl problem-large.pddl \
    > logs/large-A-lama.log 2>&1
```

All 24 runs (4 problems × 2 models × 3 configurations) were run one after the
other, never in parallel, so that runtimes are comparable.

## 4. Validating with VAL

Each plan is validated with the same domain and problem files given to the
planner, in verbose mode:

```sh
Validate -v domain-A.pddl problem-small.pddl plans/small-A-astar.plan \
    > validation/small-A-astar.val

Validate -v domain-A.pddl problem-large.pddl plans/large-A-lama.plan.9 \
    > validation/large-A-lama.9.val
```

Each `.val` file contains the type check of every action, a step-by-step
replay of the plan and, on the last lines, `Plan valid` and
`Final value: <plan cost>`.

## 5. The folder `problem-large-60min-8GB/`

With the required limits (5 min, 4 GB), A* + LM-cut does not solve
`problem-large.pddl` under either model; in both cases the limit reached is
time, not memory. To check whether a longer limit would help, we ran it again
on Model A with a 60-minute time limit and an 8 GB memory limit:

```sh
docker run --rm -v "$PWD":/work -w /work aibasel/downward \
    --overall-time-limit 60m --overall-memory-limit 8G \
    domain-A.pddl problem-large.pddl --search "astar(lmcut())" \
    > problem-large-60min-8GB/large-A-astar.log 2>&1
```

The log was produced before the domain files were renamed, so it shows the
old name `domain_a.pddl`; the content of the domain is the same.

A* still stopped at the time limit (3587 s) with no plan, after about 2.4
million expanded states. It had expanded every state with f < 48, so the
optimal cost of Model A is at least 48. Peak memory was only about 550 MB, so
time, not memory, is the bottleneck. This is an extra experiment and is not
part of the main results table, which keeps the required 5-minute limit.

## 6. The file `results.csv`

One row per run (24 rows), with the same data as the results tables of the
report. The main columns are `instance`, `model`, `planner`, `solved`, `time`
(total planner time, s), `length`, `cost`, `recharges`, `expanded`,
`best_plan` and `val`. For anytime LAMA, `cost_sequence` lists the cost of
every plan it found, and `best_found_s` the time at which the best one was
found.

## 7. The folder `plans/` (all generated plans)

`plans/` contains every plan written by Fast Downward: 60 files for the 24
runs (one file per LAMA-first or A* run, one file per improvement for anytime
LAMA). Each plan has a VAL output with the same name in `validation/`.
The best plan of each instance and model (marked \*) is printed in full in
Appendix B of the report, and the VAL output of one plan per instance is in
Appendix C.

| Run (`logs/<run>.log`) | Plan file(s) in `plans/` | Cost | VAL file in `validation/` |
|---|---|---:|---|
| small-A-lamafirst | small-A-lamafirst.plan | 10 | small-A-lamafirst.val |
| small-A-astar | small-A-astar.plan | 10\* | small-A-astar.val |
| small-A-lama | small-A-lama.plan.1 | 10 | small-A-lama.\<N\>.val |
| small-B-lamafirst | small-B-lamafirst.plan | 10 | small-B-lamafirst.val |
| small-B-astar | small-B-astar.plan | 10\* | small-B-astar.val |
| small-B-lama | small-B-lama.plan.1 | 10 | small-B-lama.\<N\>.val |
| medium-A-lamafirst | medium-A-lamafirst.plan | 47 | medium-A-lamafirst.val |
| medium-A-astar | medium-A-astar.plan | 27\* | medium-A-astar.val |
| medium-A-lama | medium-A-lama.plan.1 … .7 | 27 | medium-A-lama.\<N\>.val |
| medium-B-lamafirst | medium-B-lamafirst.plan | 54 | medium-B-lamafirst.val |
| medium-B-astar | medium-B-astar.plan | 31\* | medium-B-astar.val |
| medium-B-lama | medium-B-lama.plan.1 … .8 | 31 | medium-B-lama.\<N\>.val |
| large-A-lamafirst | large-A-lamafirst.plan | 91 | large-A-lamafirst.val |
| large-A-astar | (none: unsolved, time limit) | – | – |
| large-A-lama | large-A-lama.plan.1 … .9 | 54\* | large-A-lama.\<N\>.val |
| large-B-lamafirst | large-B-lamafirst.plan | 105 | large-B-lamafirst.val |
| large-B-astar | (none: unsolved, time limit) | – | – |
| large-B-lama | large-B-lama.plan.1 … .6 | 65\* | large-B-lama.\<N\>.val |
| large-1drone-A-lamafirst | large-1drone-A-lamafirst.plan | 99 | large-1drone-A-lamafirst.val |
| large-1drone-A-astar | large-1drone-A-astar.plan | 69\* | large-1drone-A-astar.val |
| large-1drone-A-lama | large-1drone-A-lama.plan.1 … .9 | 69 | large-1drone-A-lama.\<N\>.val |
| large-1drone-B-lamafirst | large-1drone-B-lamafirst.plan | 119 | large-1drone-B-lamafirst.val |
| large-1drone-B-astar | large-1drone-B-astar.plan | 95\* | large-1drone-B-astar.val |
| large-1drone-B-lama | large-1drone-B-lama.plan.1 … .5 | 95 | large-1drone-B-lama.\<N\>.val |

For anytime LAMA the cost is that of the last (best) plan `.plan.N`; the costs
of all its plans are in the `cost_sequence` column of `results.csv`.
