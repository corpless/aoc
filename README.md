# Advent of Code Solutions

Project structure

```
2024
└── aocgleam # per language
    ├── src
    │   └── users # dir per user
    │       └── susliko
    ├── inputs
    │   └── day1 # test data
    └── test
2025
└── ocaml # per language
    ├── susliko # dir per user
    │   ├── dayX.ml # script per day
    │   └── dune # list of all scripts here
    └── inputs # it's here, but in .gitignore
        └── day1 # test data

```

## Gleam
To run a module (when inside [./aocgleam](./aocgleam)):
```
gleam run -m users/<user>/<modulename>
```

## Ocaml

```
opam install lp lp-glpk
dune exec <user>/<filename>.exe
```

e.g. `dune exec susliko/day01.exe`

For "watch" mode add '-w' at the end.
