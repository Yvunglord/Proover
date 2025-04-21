FROM ocaml/opam:ubuntu-24.10-ocaml-5.3

WORKDIR /app

COPY . .

RUN sudo apt-get update && sudo apt-get upgrade -y && \
    opam install . --deps-only -y && \
    opam install ppx_expect alcotest zanuda angstrom -y && \
    rm -rf /var/lib/apt/lists/*

RUN eval $(opam env)

CMD ["dune", "build"]
