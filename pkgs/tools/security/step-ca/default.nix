{ stdenv
, lib
, fetchFromGitHub
, buildGoModule
, coreutils
, pcsclite
, PCSC
, pkg-config
, hsmSupport ? true
}:

buildGoModule rec {
  pname = "step-ca";
  version = "0.17.4";

  src = fetchFromGitHub {
    owner = "smallstep";
    repo = "certificates";
    rev = "v${version}";
    sha256 = "sha256-X4dOrd/wxtYLw3C4Lj88RV/J6CEkmsOeqtiVX/6VFHg=";
  };

  vendorSha256 = "sha256-/8Glo+U8MS8Y8mKECgTAB7JWmp/rjMQhG4nZkNs+Zgs=";

  ldflags = [ "-buildid=" ];

  nativeBuildInputs = lib.optionals hsmSupport [ pkg-config ];

  buildInputs =
    lib.optionals (hsmSupport && stdenv.isLinux) [ pcsclite ]
    ++ lib.optionals (hsmSupport && stdenv.isDarwin) [ PCSC ];

  postPatch = ''
    substituteInPlace systemd/step-ca.service --replace "/bin/kill" "${coreutils}/bin/kill"
  '';

  preBuild = ''
    ${lib.optionalString (!hsmSupport) "export CGO_ENABLED=0"}
  '';

  postInstall = ''
    install -Dm444 -t $out/lib/systemd/system systemd/step-ca.service
  '';

  # Tests start http servers which need to bind to local addresses:
  # panic: httptest: failed to listen on a port: listen tcp6 [::1]:0: bind: operation not permitted
  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "A private certificate authority (X.509 & SSH) & ACME server for secure automated certificate management, so you can use TLS everywhere & SSO for SSH";
    homepage = "https://smallstep.com/certificates/";
    license = licenses.asl20;
    maintainers = with maintainers; [ cmcdragonkai mohe2015 ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
