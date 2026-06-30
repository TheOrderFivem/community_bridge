# Contributing to Community Bridge

Thanks for your interest in contributing to `community_bridge`. This project grows through community contributions, and these guidelines exist to keep it consistent, usable, and maintainable over the long run.

These are proposed guidelines rather than strict rules. Feedback is welcome, and the goal is a balanced structure with sensible checks and balances. If something here does not fit your situation, open a discussion in the [Community Discord](https://discord.gg/MukwBuJjP7) and we will figure it out together.

---

## 1. Resource Relevance and Usage

New resource integrations should meet at least one of the following:

* The resource is active on **100 or more servers**, or
* The resource has a **verifiable dependency** on `community_bridge`.

Exceptions can be made on a case by case basis, especially when the integration adds clear value or supports the project goals. Lower usage resources can still help grow adoption, so do not let the threshold stop you from starting a conversation.

One thing worth keeping in mind: the bridge currently loads every module regardless of whether a server actually uses it. Each added integration therefore has a small memory cost for everyone running the bridge, which is the main reason the usage threshold exists.

---

## 2. Avoiding Breaking Changes

Breaking changes should be avoided unless they are truly necessary. When a change requires deprecating existing behavior:

* Provide a grace period of **2 to 4 months** before removal or a major change.
* Document the **deprecation notice** clearly in the code, ideally with a deprecation date so everyone knows the timeline.

This gives developers who depend on the bridge enough time to adapt and makes transitions a lot smoother.

---

## 3. Documentation and Testing

Every addition should include:

* **At least one usage example**
* **IntelliSense style comments** so editors can surface argument and return types
* **Unit test coverage** for the new behavior

Good documentation and tests reduce trial and error for the next person and make your contribution easier to adopt.

---

## 4. Membership and Contributor Expectations

Maintainers and members are expected to review pull requests and give feedback, both to keep development moving and to give contributors proper recognition. Basic activity expectations may apply to members, while contributors keep permanent credit for their work.

---

## 5. Pull Request Workflow

* Target the `dev` branch with your pull request, not `main`.
* Pull the latest changes from `dev` and resolve any merge conflicts before you open the PR.
* Follow the existing code style of the project.
* Test your changes and confirm they work as expected.
* Fill out the [pull request template](.github/pull_request_template.md) so reviewers have the context they need.

---

## Questions

If anything is unclear or you want to discuss an exception before you start, join the [Community Discord](https://discord.gg/MukwBuJjP7). These guidelines are meant to grow with the project, so input from contributors is always welcome.
