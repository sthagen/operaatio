#! /usr/bin/env bash
# Deploy emacs as compiled from a public proxy repository for system wide use
tool="emacs"
binary="${tool}"
server_url="https://ftp.gnu.org"
provider_org="gnu"
repo_dir="${tool}"
version=${1:-28.1}
common_base_url="${server_url}/pub/${provider_org}/${repo_dir}/${tool}-"
keyring_url="${server_url}/${provider_org}/${provider_org}-keyring.gpg"
build="${HOME}/d/${tool}"
prefix="/opt/${tool}"
bin_path="${prefix}/bin"
profile_path="${HOME}"/.bashrc
profile_token="export PATH=${bin_path}:\$HOME/.emacs.d/bin:\$PATH"

sudo mkdir -p "${prefix}" && sudo chown "${USER}":"${USER}" "${prefix}" || exit 1

mkdir -p "${build}" && cd "${build}"  || exit 1

printf "Installing emacs(%s) from upstream source below (%s) ...\n" "${version}" "${prefix}"
curl -kLO "${common_base_url}${version}".tar.xz
curl -kLO "${common_base_url}${version}".tar.xz.sig
curl -kLO "${keyring_url}"

gpg --verify --keyring ./"${provider_org}"-keyring.gpg "${tool}-${version}.tar.xz.sig" || exit 1

tar -axf "${tool}-${version}".tar.xz && cd "${tool}-${version}" || exit 1

# sudo apt install libxpm-dev libjpeg-dev libgif-dev libtiff-dev libcairo-dev libharfbuzz-dev

./configure --prefix="${prefix}" --with-native-compilation --with-x-toolkit=no

make -j"$(nproc)"

if ! grep -q "${profile_token}" "${profile_path}"
then
    printf "Prepending tool bin path %s to PATH by appending to profile %s" "${bin_path}" "${profile_path}"
    {
        printf "\n# -+- experimental cppcheck infrastructure\n"
        printf "%s\n" "${profile_token}"
        printf "# -+-\n"
    } >> "${profile_path}"
fi

printf "Testing the freshly build and deployed %s using the binary %s ...\n" "${tool}" "${bin_path}/${binary}"
which "${binary}"
"${binary}" --help
"${binary}" --version
