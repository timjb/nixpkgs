{ stdenv
, buildPythonPackage
, fetchPypi
, isPy3k
# python dependencies
, click
, configparser ? null
, dateutil
, etelemetry
, filelock
, funcsigs
, future
, futures
, mock
, networkx
, nibabel
, numpy
, packaging
, pathlib2
, prov
, psutil
, pybids
, pydot
, pytest
, pytest_xdist
, pytest-forked
, scipy
, simplejson
, traits
, xvfbwrapper
, pytestcov
, codecov
# other dependencies
, which
, bash
, glibcLocales
, callPackage
}:

assert !isPy3k -> configparser != null;

let

 # This is a temporary convenience package for changes waiting to be merged into the primary rdflib repo.
 neurdflib = callPackage ./neurdflib.nix { };

in

buildPythonPackage rec {
  pname = "nipype";
  version = "1.2.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "a79c7a72897d81985d20a8c805465285400b59a45ddc527cda44026795fd1c47";
  };

  postPatch = ''
    substituteInPlace nipype/interfaces/base/tests/test_core.py \
      --replace "/usr/bin/env bash" "${bash}/bin/bash"
  '';

  propagatedBuildInputs = [
    click
    dateutil
    etelemetry
    filelock
    funcsigs
    future
    networkx
    neurdflib
    nibabel
    numpy
    packaging
    prov
    psutil
    pydot
    scipy
    simplejson
    traits
    xvfbwrapper
  ] ++ stdenv.lib.optionals (!isPy3k) [
    configparser
    futures
    pathlib2 # darwin doesn't receive this transitively, but it is in install_requires
  ];

  checkInputs = [
    pybids
    codecov
    glibcLocales
    mock
    pytest
    pytest-forked
    pytest_xdist
    pytestcov
    which
  ];

  # checks on darwin inspect memory which doesn't work in build environment
  doCheck = !stdenv.isDarwin;
  # ignore tests which incorrect fail to detect xvfb
  checkPhase = ''
    LC_ALL="en_US.UTF-8" pytest -v nipype -k 'not display'
  '';

  meta = with stdenv.lib; {
    homepage = https://nipy.org/nipype/;
    description = "Neuroimaging in Python: Pipelines and Interfaces";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ashgillman ];
  };
}
