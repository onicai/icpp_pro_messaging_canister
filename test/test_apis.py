"""Test canister APIs

First deploy the canister as a non-default user, then run:

$ pytest -vv [--network=ic]

"""

# pylint: disable=missing-function-docstring, unused-import, wildcard-import, unused-wildcard-import, line-too-long, unused-argument

from pathlib import Path
from typing import Dict
import pytest
from icpp.smoketest import call_canister_api

# Path to the dfx.json file
DFX_JSON_PATH = Path(__file__).parent / "../dfx.json"

# Canister in the dfx.json file we want to test
CANISTER_NAME = "messaging"

# for IC network, the update calls take longer
UPDATE_TIMEOUT_SECONDS = 60


def test__health_anonymous(identity_anonymous: Dict[str, str], network: str) -> None:
    response = call_canister_api(
        dfx_json_path=DFX_JSON_PATH,
        canister_name=CANISTER_NAME,
        canister_method="health",
        canister_argument="()",
        network=network,
    )
    expected_response = "(variant { Err = variant { StatusCode = 403 : nat16 } })"
    assert response == expected_response


def test__health(identity_default: Dict[str, str], network: str) -> None:
    response = call_canister_api(
        dfx_json_path=DFX_JSON_PATH,
        canister_name=CANISTER_NAME,
        canister_method="health",
        canister_argument="()",
        network=network,
    )
    expected_response = "(variant { Ok = record { status_code = 200 : nat16;} })"
    assert response == expected_response


def test__set_message_anonymous(
    identity_anonymous: Dict[str, str], network: str
) -> None:
    response = call_canister_api(
        dfx_json_path=DFX_JSON_PATH,
        canister_name=CANISTER_NAME,
        canister_method="set_message",
        canister_argument='(record { message = "Many thanks for using icpp-pro 💻️" })',
        network=network,
        timeout_seconds=UPDATE_TIMEOUT_SECONDS,
    )
    expected_response = "(variant { Err = variant { StatusCode = 403 : nat16 } })"
    assert response == expected_response


def test__set_message_default_non_controller(
    identity_default: Dict[str, str], network: str
) -> None:
    response = call_canister_api(
        dfx_json_path=DFX_JSON_PATH,
        canister_name=CANISTER_NAME,
        canister_method="set_message",
        canister_argument='(record { message = "Many thanks for using icpp-pro 💻️" })',
        network=network,
        timeout_seconds=UPDATE_TIMEOUT_SECONDS,
    )
    expected_response = "(variant { Err = variant { StatusCode = 403 : nat16 } })"
    assert response == expected_response


def test__set_message_controller(network: str) -> None:
    response = call_canister_api(
        dfx_json_path=DFX_JSON_PATH,
        canister_name=CANISTER_NAME,
        canister_method="set_message",
        canister_argument='(record { message = "Many thanks for using icpp-pro 💻️" })',
        network=network,
        timeout_seconds=UPDATE_TIMEOUT_SECONDS,
    )
    expected_response = '(variant { Ok = record { message = "Many thanks for using icpp-pro 💻\\u{fe0f}";} })'
    assert response == expected_response


def test__get_message_anonymous(
    identity_anonymous: Dict[str, str], network: str
) -> None:
    response = call_canister_api(
        dfx_json_path=DFX_JSON_PATH,
        canister_name=CANISTER_NAME,
        canister_method="get_message",
        canister_argument="()",
        network=network,
        timeout_seconds=UPDATE_TIMEOUT_SECONDS,
    )
    expected_response = "(variant { Err = variant { StatusCode = 403 : nat16 } })"
    assert response == expected_response


def test__get_message_default_non_controller(
    identity_default: Dict[str, str], network: str
) -> None:
    response = call_canister_api(
        dfx_json_path=DFX_JSON_PATH,
        canister_name=CANISTER_NAME,
        canister_method="get_message",
        canister_argument="()",
        network=network,
        timeout_seconds=UPDATE_TIMEOUT_SECONDS,
    )
    expected_response = '(variant { Ok = record { message = "Many thanks for using icpp-pro 💻\\u{fe0f}";} })'
    assert response == expected_response


def test__get_message_controller(network: str) -> None:
    response = call_canister_api(
        dfx_json_path=DFX_JSON_PATH,
        canister_name=CANISTER_NAME,
        canister_method="get_message",
        canister_argument="()",
        network=network,
        timeout_seconds=UPDATE_TIMEOUT_SECONDS,
    )
    expected_response = '(variant { Ok = record { message = "Many thanks for using icpp-pro 💻\\u{fe0f}";} })'
    assert response == expected_response
