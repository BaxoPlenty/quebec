<div align="center">

[![](/assets/banner.png)][docs_link]

<br/>

# Quebec

An **open-source, flexible** Roblox game framework.<br/>
Easily integrate game logic using **services & controllers**.<br/>
Provides multiple **opt-in modules and utilities** for a seamless dev experience.

[![docs_badge]][docs_link]
[![discord_badge]][discord_link]
[![setup_badge]][setup_link]

[![license_badge]](/LICENSE)
![stars_badge]

</div>

<details>
<summary><kbd>Table of contents</kbd></summary>

- [Quebec](#quebec)
  - [👋 Getting Started](#-getting-started)
  - [✨ Features](#-features)
    - [📁 Services \& Controllers (Singletons)](#-services--controllers-singletons)
    - [⚡ Lifecycle Events](#-lifecycle-events)
    - [🌐 Built-in Networking Module](#-built-in-networking-module)
    - [📦 OOP-style Classes](#-oop-style-classes)
    - [🧠 Typed By Default](#-typed-by-default)
  - [📜 List Of Modules \& Utility Functions](#-list-of-modules--utility-functions)
  - [🤝 Contributions](#-contributions)
  - [📚 Installation \& Other Information](#-installation--other-information)

</details>

## 👋 Getting Started

> [!IMPORTANT]
>
> Quebec has not yet been battle-tested in production. Incase you encounter any problems, make sure to contact me immediately!
>
> [Discord][discord_link] - [Github Issues](https://github.com/BaxoPlenty/quebec/issues)

First of all, **thank you** for checking out Quebec! It means a lot to me. Quebec was built to **enhance the workflow** of Roblox developers **without becoming annoying to work with**.

It doesn't matter if you're a professional developer or a beginner, Quebec is simple but yet very customizable. Feedback is always welcome either via [Discord][discord_link] or [Github Issues](https://github.com/BaxoPlenty/quebec/issues).

[![jump_badge]](#-installation--other-information)

## ✨ Features

### 📁 Services & Controllers (Singletons)

Utilize **services (server-sided)** and **controllers (client-sided)** to structure your game logic. These are referred to as **singletons**, because they are only **instantiated once**.

Singletons can act on various game events by registering handlers for [lifecycle events](#-lifecycle-events).

### ⚡ Lifecycle Events

Lifecycle events are used to connect [singletons](#-services--controllers) to **events** such as:

-   the start/stop of a singleton
-   game loops via `RunService`
-   [custom lifecycle events]() created with `Quebec.lifecycle`

### 🌐 Built-in Networking Module

Quebec provides a set of **built-in modules**. One of them is a **fully featured networking module** containing:

-   `RemoteEvents`
-   `RemoteFunctions`
-   `UnreliableRemoteEvent`

The networking module also **supports two-way-events (client to server, server to client) and network obfuscation (via name obfuscation)**.

### 📦 OOP-style Classes

Another useful feature is the `Quebec.util.class` utility function which **creates an OOP-style class** from just a constructor and a prototype.

### 🧠 Typed By Default

Another goal is to have a great integration with the **LuaU type system** for **reliable autocompletions**.

## 📜 List Of Modules & Utility Functions

<details>
<summary><kbd>Networking</kbd></summary>

</details>

<details>
<summary><kbd>Janitor</kbd></summary>

</details>

<details>
<summary><kbd>Signal</kbd></summary>

</details>

<details>
<summary><kbd>Channel</kbd></summary>

</details>

<details>
<summary><kbd>Quebec.util.class</kbd></summary>

</details>

## 🤝 Contributions

Contributions are always welcome. We recommend to [check the guidelines](/CONTRIBUTING.md).

## 📚 Installation & Other Information

You can find all **other information including guides** on our documentation:

[![docs_badge]][docs_link]

[docs_link]: https://baxoplenty.gitbook.io/quebec-docs
[discord_link]: https://discord.gg/edfQBBz9ch
[setup_link]: https://github.com/BaxoPlenty/quebec-rojo-setup

[docs_badge]: https://img.shields.io/badge/_-Documentation-_?style=for-the-badge&logo=gitbook&logoColor=%23fff&labelColor=%23121212&color=%23000000
[discord_badge]: https://img.shields.io/discord/1393751483467567256?style=for-the-badge&logo=discord&logoColor=%23fff&label=%20&labelColor=%23121212&color=%23000
[setup_badge]: https://img.shields.io/badge/_-Example_Setup_(Rojo)-_?style=for-the-badge&logo=github&logoColor=%23fff&labelColor=%23121212&color=%23000000
[license_badge]: https://img.shields.io/badge/License-MIT-_?style=for-the-badge&logoColor=%23fff&labelColor=%23121212&color=%23000
[stars_badge]: https://img.shields.io/github/stars/BaxoPlenty/quebec?style=for-the-badge&logoColor=%23fff&labelColor=%23121212&color=%23ffff00
[jump_badge]: https://img.shields.io/badge/_-Jump%20To%20Installation-_?style=for-the-badge&logoColor=%23fff&labelColor=%23121212&color=%23000000
