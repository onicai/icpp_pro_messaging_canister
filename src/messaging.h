#pragma once

#include "wasm_symbol.h"

void set_message() WASM_SYMBOL_EXPORTED("canister_update set_message");
void get_message() WASM_SYMBOL_EXPORTED("canister_query get_message");