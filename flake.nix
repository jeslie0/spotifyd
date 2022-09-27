{
  description = "A very basic flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let pkgs = nixpkgs.legacyPackages.${system};
          withALSA = true;
          withPulseAudio = true;
          withPortAudio = true;
          withMpris = true;
          withKeyring = true;
          spotifyd = pkgs.fetchgit {
            url = "https://github.com/Spotifyd/spotifyd";
            rev = "a4316df958b1d29c5b22c318ee00f6df96f9c6c7";
            sha256 = "sha256-hIbWuiterZ8S0GNInqmQl6V6aK08Eq+AZ89Vv8U69+s";
          };
      in
        {
          defaultPackage = pkgs.rustPackages.rustPlatform.buildRustPackage rec {
            name = "spotifyd-full";

            src = spotifyd;

            cargoSha256 = "sha256-JsnGKNlsjV/IJGXdl/cqrXjyff8KTYvgOSHLENJne8A=";

            nativeBuildInputs = [ pkgs.pkg-config ];

            buildInputs = with pkgs;
              [ pkgs.openssl ]
              ++ lib.optional withALSA alsa-lib
              ++ lib.optional withPulseAudio libpulseaudio
              ++ lib.optional withPortAudio portaudio
              ++ lib.optional (withMpris || withKeyring) dbus;

            buildNoDefaultFeatures = true;
            buildFeatures = with pkgs;
              lib.optional withALSA "alsa_backend"
              ++ lib.optional withPulseAudio "pulseaudio_backend"
              ++ lib.optional withPortAudio "portaudio_backend"
              ++ lib.optional withMpris "dbus_mpris"
              ++ lib.optional withKeyring "dbus_keyring";

            doCheck = false;

            meta = with pkgs.lib; {
              description = "An open source Spotify client running as a UNIX daemon";
              homepage = "https://github.com/Spotifyd/spotifyd";
              changelog = "https://github.com/Spotifyd/spotifyd/raw/v${version}/CHANGELOG.md";
              license = licenses.gpl3Plus;
              maintainers = with maintainers; [ anderslundstedt Br1ght0ne marsam ];
              platforms = platforms.unix;
            };
          };
        }
    );

}
