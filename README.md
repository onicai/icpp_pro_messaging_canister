[![cicd-mac](https://github.com/onicai/icpp_pro_messaging_canister/actions/workflows/cicd-mac.yml/badge.svg)](https://github.com/onicai/icpp_pro_messaging_canister/actions/workflows/cicd-mac.yml)
[![cicd-ubuntu](https://github.com/onicai/icpp_pro_messaging_canister/actions/workflows/cicd-ubuntu.yml/badge.svg)](https://github.com/onicai/icpp_pro_messaging_canister/actions/workflows/cicd-ubuntu.yml)

# icpp-pro Messaging Canister

The C++ code is running in canister [ahlje-dqaaa-aaaag-aua5q-cai](https://dashboard.internetcomputer.org/canister/ahlje-dqaaa-aaaag-aua5q-cai)

icpp-pro calls the `get_message` query endpoint at the end of a run and prints the message retrieved.

This mechanism allows us to communicate with you, our favorite C++ developer.

**Zero information is collected, as you can verify in the code.**

# Try it out

Call the `get_message` endpoint after logging in at [Candid UI](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=ahlje-dqaaa-aaaag-aua5q-cai)

# Development of this canister

This section is for contributors to this canister:

- Install dfx:

  ```bash
  sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

  # Configure your shell
  source "$HOME/.local/share/dfx/env"
  ```

- Clone the repo

  ```bash
  # Clone this repo
  git clone git@github.com:onicai/icpp_pro_messaging_canister.git
  ```

- Create a Python environment with dependencies installed

  ```bash
  # We use MiniConda
  conda create --name icpp_pro_messaging_canister python=3.11
  conda activate icpp_pro_messaging_canister

  # Install the python dependencies
  # From root of icpp_pro_messaging_canister repo:
  pip install -r requirements.txt
  ```

- Build & Deploy the canister `messaging`:

  - Compile & link to WebAssembly (wasm):

    ```bash
    make build-info-cpp-wasm
    icpp build-wasm

    # Speed up compilation the second time:
    icpp build-wasm --to-compile mine-no-lib
    ```

  - Start the local network:

    ```bash
    dfx start --clean
    ```

  - Build & Deploy the wasm to a canister on the local network:

    ```bash
    dfx deploy
    ```

  - Check the health endpoint:

    ```bash
    # query call: all non-anonymous users can call this
    $ dfx canister call messaging health
    (variant { Ok = record { status_code = 200 : nat16 } })
    ```

  - Set a message:

    ```bash
    # update call: only a controller from onicai can call this
    $ dfx canister call messaging set_message '(record {
      message = "Thank you for using icpp-pro 💻️\n👉️Learn more at https://www.onicai.com/#/icpp-pro"
    })'

    (
      variant {
        Ok = record {
          message = "Thank you for using icpp-pro 💻️\n👉️Learn more at https://www.onicai.com/#/icpp-pro";
        }
      },
    )
    ```

  - Get the message:
    ```bash
    # query call: all non-anonymous users can call this
    $ dfx canister call messaging get_message
    (
      variant {
        Ok = record {
          message = "Thank you for using icpp-pro 💻️\n👉️Learn more at https://www.onicai.com/#/icpp-pro";
        }
      },
    )
    ```

- Install your pre-commit file

  Read instructions for your OS in:

  - pre-commit-mac
  - pre-commit-ubuntu

  This is optional if you never plan to check anything in.
  If you do, please install it, so you will always check code format & linting before a commit.
  If you don't, the CI/CD will fail upon your push to GitHub.

# Smoke testing the deployed canioster

You can run a smoketest on the deployed canister:

- Deploy as described above, with a non-default dfx identity.
  It is important to use a non-default dfx identity, so the pytest tests can distinguish between a canister controller and are non-controller

- Run the smoketests:
  ```bash
  dfx identity use <a non-default identity>
  pytest -vv
  ```
