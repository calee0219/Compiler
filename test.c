#pragma source on

int main() {
  int idx;
  for (idx = 1e-2; idx < 10.0; ++idx) {
    print("%d", idx);
    // this is a comment
    /* this is also a comment with ,.*[] ?
   TTT
*/ print("hi");
  }
}
