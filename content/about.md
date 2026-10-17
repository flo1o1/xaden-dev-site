---
title: "About"
---

Xaden is made and maintained by Florian Auer, a freelance software creator in Freiburg, Germany.

## Why

AI has made writing software much faster, but not better. Assistants invent rules, skip checks and
drift from what was asked. I have no time for repetitive work and no wish to clean up bad software
afterwards. I also wanted to learn how far rules and automated checks can steer an assistant.

There was a second reason. A friend runs a business and needs highly customized software, but he is
not a developer and his budget is small. Xaden helps keep such a project out of trouble: requirements
written down, checks that run on every commit, and a security review before each release.

## The name

AI sometimes applies lesser magic (scripts) and sometimes real magic (a language model). It draws a lot of
energy from its surroundings, and sometimes it is good and sometimes it is not. The name is a tribute to
Rebecca Yarros's Empyrean novels. If you have not read them, I will not spoil anything. If you have, you
know why this tool is called Xaden.

## License

Xaden is open source under the [MIT license](https://github.com/flo1o1/xaden-dev/blob/main/LICENSE).
Projects you generate with it do not inherit that license; you choose one for each project.

## Release signing key

Xaden releases are signed with an SSH key, so you can check that a download comes from the maintainer.
Compare this key and fingerprint with the line in
[`release-signers`](https://github.com/flo1o1/xaden-dev/blob/main/release-signers) of the repository.

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY0fmJjw8aLB9x1otNvJkgIgZ2Q7w5vHcwjskJTOgQy release@xaden.dev
SHA256:hK0RtYSppWVuMr6H5kdSfWE1FPO4vM3Un3bggaggqSE
```

## Contact

Write to [hello@xaden.dev](mailto:hello@xaden.dev) for questions, feedback and security reports
(see [security.txt](/.well-known/security.txt)). Issues and pull requests go to the
[GitHub repository](https://github.com/flo1o1/xaden-dev).
