#! /usr/bin/env bash
# Deploy cppcheck as compiled from a public proxy repository for system wide use
tool="cppcheck"
binary="${tool}"
server_url="https://github.com"
provider_org="sthagen"
repo_dir="danmar-${tool}"
upstream_repo_url="${server_url}/${provider_org}/${repo_dir}"
build="${HOME}/d/${tool}"
prefix="/opt/${tool}"
bin_path="${prefix}/bin"
profile_path="${HOME}"/.bashrc
profile_token="export PATH=${bin_path}:\$PATH"

sudo mkdir -p "${prefix}" && sudo chown "${USER}":"${USER}" "${prefix}" || exit 1

mkdir -p "${build}" && cd "${build}"  || exit 1

[ -d "${build}/${repo_dir}" ] || git clone "${upstream_repo_url}"

cd "${repo_dir}" || exit 1

git pull  && rm -fr build && \
  cmake -DCMAKE_INSTALL_PREFIX="${prefix}" -S . -B build && \
  cmake --build build --config Release --target install

if ! grep -q "${profile_token}" "${profile_path}"
then
    printf "Prepending tool bin path %s to PATH by appending to profile %s" "${bin_path}" "${profile_path}"
    {
        printf "\n# -+- experimental cppcheck infrastructure\n"
        printf "%s\n" "${profile_token}"
        printf "# -+-\n"
    } >> "${profile_path}"
    $SHELL
fi

printf "Testing the freshly build and deployed %s using the binary %s ...\n" "${tool}" "${bin_path}/${binary}"
which "${binary}"
"${binary}" --help
"${binary}" --version
