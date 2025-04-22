#include "health.h"

#include <iostream>
#include <string>

#include "ic_api.h"

void health() {
  IC_API ic_api(CanisterQuery{std::string(__func__)}, false);

  CandidTypePrincipal caller = ic_api.get_caller();
  if (caller.is_anonymous()) {
    ic_api.to_wire(CandidTypeVariant{
        "Err", CandidTypeVariant{"StatusCode", CandidTypeNat16{403}}});
    return;
  }

  CandidTypeRecord status_code_record;
  status_code_record.append("status_code", CandidTypeNat16{200});
  ic_api.to_wire(CandidTypeVariant{"Ok", status_code_record});
}