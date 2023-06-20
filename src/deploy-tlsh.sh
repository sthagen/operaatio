#! /usr/bin/env bash
# Deploy tlsh compiled from source
tool="tlsh"
binary="${tool}"
ts_start="$(date +'%Y-%m-%d %H:%M:%S +00:00')"
printf "# %s\n" "==========================================================================================="
printf "deploy-%s starting at %s\n" "${tool}" "${ts_start}"
printf "# %s\n" "-------------------------------------------------------------------------------------------"
server_url="https://github.com"
provider_org="sthagen"
repo_dir="trendmicro-${tool}"
upstream_repo_url="${server_url}/${provider_org}/${repo_dir}"
prefix="/opt/${tool}"
bin_path="${prefix}/bin"
src_path="${prefix}/src"
profile_path="${HOME}"/.bashrc
profile_token="export PATH=${bin_path}:\$PATH"

sudo mkdir -p "${prefix}" && sudo chown "${USER}":"${USER}" "${prefix}" || exit 1
sudo mkdir -p "${src_path}" && sudo chown "${USER}":"${USER}" "${src_path}" && cd "${src_path}"  || exit 1

[ -d "${src_path}/${repo_dir}" ] || git clone "${upstream_repo_url}"

cd "${repo_dir}" || exit 1

git pull --rebase && rm -fr build && \
  cmake -DCMAKE_INSTALL_PREFIX="${prefix}" -DTLSH_CHECKSUM_1B=1 -S . -B build && \
  cmake --build build --target install --config Release

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
which -a "${binary}"
"${binary}" --help
"${binary}" --version
app="$(which ${binary})"
file "${app}"
stat "${app}"
gen-fingerprints "${app}"
ts_stop="$(date +'%Y-%m-%d %H:%M:%S +00:00')"
printf "# %s\n" "-------------------------------------------------------------------------------------------"
printf "deploy-%s complete: [%s, %s]\n" "${tool}" "${ts_start}" "${ts_stop}"
printf "# %s\n" "==========================================================================================="
