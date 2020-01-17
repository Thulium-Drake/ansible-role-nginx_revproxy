local Converge(distro) = {
  name: "Converge - "+distro,
  image: "quay.io/ansible/molecule",
  commands: [
    "molecule destroy",
    "molecule converge",
    "molecule idempotence",
    "molecule destroy",
  ],
  environment:
    { MOLECULE_DISTRO: +distro, },
  privileged: true,
  volumes: [
    { name: "docker", path: "/var/run/docker.sock" },
  ],
};

[
  {
    name: "Lint",
    kind: "pipeline",
    steps: [
      {
        name: "Lint code",
        image: "quay.io/ansible/molecule",
        commands: [
          "molecule lint",
          "molecule syntax"
        ]
      }
    ]
  },
  {
    kind: "pipeline",
    name: "Test",
    steps: [
      Converge("debian9"),
      Converge("debian10"),
      Converge("ubuntu1804"),
    ],
    volumes: [
      { name: "docker",
        host: { path: "/var/run/docker.sock" }
      },
    ],

    depends_on: [
      "Lint",
    ],
  },
  {
    name: "Publish",
    kind: "pipeline",
    clone:
      { disable: true },
    steps: [
      {
        name: "Ansible Galaxy",
        image: "quay.io/ansible/molecule",
        commands: [
          "ansible-galaxy login --github-token $$GITHUB_TOKEN",
          "ansible-galaxy import Thulium-Drake ansible-role-nginx_revproxy --role-name=nginx_revproxy",
        ],
        environment:
          { GITHUB_TOKEN: { from_secret: "github_token" } },
      },
    ],
    depends_on: [
      "Test",
    ],
  },
]
