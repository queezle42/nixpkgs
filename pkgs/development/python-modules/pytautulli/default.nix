{ lib
, aiohttp
, aresponses
, async-timeout
, buildPythonPackage
, fetchFromGitHub
, pytest-asyncio
, pytestCheckHook
, pythonOlder
}:

buildPythonPackage rec {
  pname = "pytautulli";
  version = "21.10.0";
  format = "setuptools";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "ludeeus";
    repo = pname;
    rev = version;
    sha256 = "1gi1jalwzf1aykvdmdbvr7hvfch9wbbjra87f1vzdmkb5iiirw01";
  };

  postPatch = ''
    # Upstream is releasing with the help of a CI to PyPI, GitHub releases
    # are not in their focus
    substituteInPlace setup.py \
      --replace 'version="main",' 'version="${version}",'
  '';

  propagatedBuildInputs = [
    aiohttp
    async-timeout
  ];

  checkInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
  ];

  pythonImportsCheck = [ "pytautulli" ];

  meta = with lib; {
    description = "Python module to get information from Tautulli";
    homepage = "https://github.com/ludeeus/pytautulli";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ fab ];
  };
}
