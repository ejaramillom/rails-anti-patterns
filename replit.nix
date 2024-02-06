{ pkgs }: {
  deps = [
    pkgs.ruby test.rb
    pkgs.ruby_3_1
    pkgs.rubyPackages_3_1.solargraph
  ];
}