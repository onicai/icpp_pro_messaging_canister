#include "messaging.h"
#include "ic_api.h"

std::string message = "Thank you for using icpp-pro 💻️";

void set_message() {
  IC_API ic_api(CanisterUpdate{std::string(__func__)}, false);
  CandidTypePrincipal caller = ic_api.get_caller();
  if (!ic_api.is_controller(caller)) {
    ic_api.to_wire(CandidTypeVariant{
        "Err", CandidTypeVariant{"StatusCode", CandidTypeNat16{403}}});
    return;
  }

  CandidTypeRecord r_in;
  r_in.append("message", CandidTypeText{&message});
  ic_api.from_wire(r_in);

  CandidTypeRecord r_out;
  r_out.append("message", CandidTypeText{message});
  ic_api.to_wire(CandidTypeVariant{"Ok", r_out});
}

void get_message() {
  IC_API ic_api(CanisterQuery{std::string(__func__)}, false);

  CandidTypePrincipal caller = ic_api.get_caller();
  if (caller.is_anonymous()) {
    ic_api.to_wire(CandidTypeVariant{
        "Err", CandidTypeVariant{"StatusCode", CandidTypeNat16{403}}});
    return;
  }

  CandidTypeRecord r_out;
  r_out.append("message", CandidTypeText{message});
  ic_api.to_wire(CandidTypeVariant{"Ok", r_out});
}