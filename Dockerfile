FROM ocaml/opam:ubuntu-24.04-ocaml-5.1

WORKDIR /app
COPY *.opam ./
COPY *.opam.locked ./
RUN sudo apt-get update && \
    sudo apt-get upgrade -y && \
    sudo rm -rf /var/lib/apt/lists/*
RUN opam update
RUN opam install . --deps-only -y
RUN opam install ppx_expect alcotest angstrom -y 
COPY . .
RUN eval $(opam env)
CMD ["dune", "build"]