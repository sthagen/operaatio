#! /usr/bin/env bash
# Deploy cmake as compiled from the public vendor repository for system wide use
tool="gcc"
binary="${tool}"
secondary="g++"
server_url="https://ftp.gnu.org"
provider_org="gnu"
repo_dir="gcc"
version=${1:12.1.0}
upstream_repo_url="${server_url}/${provider_org}/${repo_dir}"
build="${HOME}/d/${tool}"
prefix="/opt/${tool}"
bin_path="${prefix}/bin"
profile_path="${HOME}"/.bashrc
profile_ld_path="export LD_LIBRARY_PATH=${prefix}/lib64:\$LD_LIBRARY_PATH"
profile_token="export PATH=${bin_path}:\$PATH"

sudo mkdir -p "${prefix}" && sudo chown "${USER}":"${USER}" "${prefix}" || exit 1

mkdir -p "${build}" && cd "${build}"  || exit 1

common_base_url="${common_base_url}/${tool}/${tool}-${version}/${tool}-${version}"
curl -kLO "${common_base_url}".tar.gz
curl -kLO "${common_base_url}".tar.gz.sig
curl -kLO "${upstream_repo_url}/${provider_org}"-keyring.gpg

gpg --verify --keyring ./"${provider_org}"-keyring.gpg "${tool}-${version}.tar.gz.sig" || exit 1

tar -xzf "${tool}-${version}.tar.gz" && cd "${tool}-${version}/" || exit 1

./contrib/download_prerequisites && mkdir -p ../objdir && cd ../objdir || exit 1

"${PWD}/../${tool}-${version}/configure" --disable-multilib --prefix="${prefix}" || exit 1

make -j"$(nproc)" && make install || exit 1

if ! grep -q "${profile_token}" "${profile_path}"
then
    printf "Prepending tool bin path %s to PATH by appending to profile %s" "${bin_path}" "${profile_path}"
    {
        printf "\n# -+- experimental %s infrastructure\n" "${tool}"
        printf "%s\n" "${profile_ld_path}"
        printf "%s\n" "${profile_token}"
        printf "# -+-\n"
    } >> "${profile_path}"
    $SHELL
fi

printf "Testing the freshly build and deployed %s using the binary %s ...\n" "${tool}" "${bin_path}/${binary}"
which "${binary}"
which "${secondary}"
"${bin_path}/${binary}" --version
"${bin_path}/${secondary}" --version
ls -lrt "${bin_path}"
