#! /usr/bin/env bash
# Deploy cmake as compiled from the public vendor repository for system wide use
tool="cmake"
binary="${tool}"
server_url="https://github.com"
provider_org="Kitware"
repo_dir="CMake"
version=${1:3.23.2}
upstream_repo_url="${server_url}/${provider_org}/${repo_dir}"
build="${HOME}/d/${tool}"
prefix="/opt/${tool}"
bin_path="${prefix}/bin"
profile_path="${HOME}"/.bashrc
profile_token="export PATH=${bin_path}:\$PATH"

sudo mkdir -p "${prefix}" && sudo chown "${USER}":"${USER}" "${prefix}" || exit 1

mkdir -p "${build}" && cd "${build}"  || exit 1

common_base_url="${upstream_repo_url}"/releases/download/v"${version}"/"${tool}"-"${version}"
curl -OL "${common_base_url}"-SHA-256.txt
curl -OL "${common_base_url}".tar.gz
sha256sum -c --ignore-missing "${tool}"-"${version}"-SHA-256.txt || exit 1

kitware_signing_subkey="C6C265324BBEBDC350B513D02D2CEF1034921684"
curl -OL "${common_base_url}"-SHA-256.txt.asc
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "${kitware_signing_subkey}"
gpg --verify "${tool}"-"${version}"-SHA-256.txt.asc "${tool}"-"${version}"-SHA-256.txt || exit 1

printf "LD Library Path shall contain (%s) and value found is (%s)\n" "/opt/gcc/lib64" "${LD_LIBRARY_PATH}"

tar -xzvf "${tool}"-"${version}".tar.gz && cd "${tool}"-"${version}"/ || exit 1
./bootstrap -- -DCMAKE_INSTALL_PREFIX:PATH="${prefix}" || exit 1
make -j"$(nproc)" && make install || exit 1

if ! grep -q "${profile_token}" "${profile_path}"
then
    printf "Prepending tool bin path %s to PATH by appending to profile %s" "${bin_path}" "${profile_path}"
    {
        printf "\n# -+- experimental %s infrastructure\n" "${tool}"
        printf "%s\n" "${profile_token}"
        printf "# -+-\n"
    } >> "${profile_path}"
    $SHELL
fi

printf "Testing the freshly build and deployed %s using the binary %s ...\n" "${tool}" "${bin_path}/${binary}"
which "${tool}"
"${bin_path}/${tool}" --version
ls -lrt "${bin_path}"
"${bin_path}/ccmake" --version
"${bin_path}/ctest" --version
"${bin_path}/cpack" --version
"${tool}" --version
