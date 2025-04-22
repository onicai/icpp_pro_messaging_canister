// Main entry point for a native debug executable.
// Build it with: `icpp build-native` from the parent folder where 'icpp.toml' resides

#include "main.h"

#include <iostream>

#include "../src/health.h"
#include "../src/messaging.h"

// The Mock IC
#include "mock_ic.h"

int main() {
  MockIC mockIC(true);

  // The pretend principals of the caller
  std::string my_principal{
      "expmt-gtxsw-inftj-ttabj-qhp5s-nozup-n3bbo-k7zvn-dg4he-knac3-lae"};
  std::string anonymous_principal{"2vxsx-fae"};

  bool silent_on_trap = true;

  // -----------------------------------------------------------------------------
  // The canister health check

  // Anonymous caller should fail
  // '()' -> '(variant { Err = variant { StatusCode = 403 : nat16 } })'
  mockIC.run_test("health anonymous", health, "4449444c0000",
                  "4449444c026b019f93cde6097a6b01c5fed20100010100009301",
                  silent_on_trap, anonymous_principal);

  // '()' -> '(variant { Ok = record { status_code = 200 : nat16} })'
  mockIC.run_test("health", health, "4449444c0000",
                  "4449444c026c019aa1b2f90c7a6b01bc8a0100010100c800",
                  silent_on_trap, my_principal);

  // -----------------------------------------------------------------------------
  // Get the default message

  // Anonymous caller should fail
  // '()' -> '(variant { Err = variant { StatusCode = 403 : nat16 } })'
  mockIC.run_test("get_message anonymous", get_message, "4449444c0000",
                  "4449444c026b019f93cde6097a6b01c5fed20100010100009301",
                  silent_on_trap, anonymous_principal);

  // '()' -> '(variant { Ok = record { message = "Thank you for using icpp-pro 💻️"} })'
  mockIC.run_test(
      "get_message", get_message, "4449444c0000",
      "4449444c026c01c7ebc4d009716b01bc8a0100010100245468616e6b20796f7520666f72207573696e6720696370702d70726f20f09f92bbefb88f",
      silent_on_trap, my_principal);

  // -----------------------------------------------------------------------------
  // Set a new message

  // Anonymous caller should fail
  // '(record { message = "Many thanks for using icpp-pro 💻️" })' -> '(variant { Err = variant { StatusCode = 403 : nat16 } })'
  mockIC.run_test(
      "set_message anonymous", set_message,
      "4449444c016c01c7ebc4d009710100264d616e79207468616e6b7320666f72207573696e6720696370702d70726f20f09f92bbefb88f",
      "4449444c026b019f93cde6097a6b01c5fed20100010100009301", silent_on_trap,
      anonymous_principal);

  // '()' -> '(variant { Ok = record { message = "Many thanks for using icpp-pro 💻️" } })'
  mockIC.run_test(
      "set_message", set_message,
      "4449444c016c01c7ebc4d009710100264d616e79207468616e6b7320666f72207573696e6720696370702d70726f20f09f92bbefb88f",
      "4449444c026c01c7ebc4d009716b01bc8a0100010100264d616e79207468616e6b7320666f72207573696e6720696370702d70726f20f09f92bbefb88f",
      silent_on_trap, my_principal);

  // '()' -> '(variant { Ok = record { message = "Many thanks for using icpp-pro 💻️"} })'
  mockIC.run_test(
      "get_message new", get_message, "4449444c0000",
      "4449444c026c01c7ebc4d009716b01bc8a0100010100264d616e79207468616e6b7320666f72207573696e6720696370702d70726f20f09f92bbefb88f",
      silent_on_trap, my_principal);

  // -----------------------------------------------------------------------------
  // returns 1 if any tests failed
  return mockIC.test_summary();
}
