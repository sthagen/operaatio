#! /usr/bin/env bash
# Deploy openexr compiled from source
tool="openexr"
binary="exrinfo"
server_url="https://github.com"
provider_org="sthagen"
repo_dir="AcademySoftwareFoundation-openexr"
upstream_repo_url="${server_url}/${provider_org}/${repo_dir}"
prefix="/opt/${tool}"
bin_path="${prefix}/bin"
# lib_path="${prefix}/lib"
src_path="${prefix}/src"
profile_path="${HOME}"/.bashrc
profile_root="export OPENEXR_ROOT=/opt/${tool}"
profile_token="export PATH=${bin_path}:\$PATH"

sudo mkdir -p "${prefix}" && sudo chown "${USER}":"${USER}" "${prefix}" || exit 1
sudo mkdir -p "${src_path}" && sudo chown "${USER}":"${USER}" "${src_path}" && cd "${src_path}"  || exit 1

[ -d "${src_path}/${repo_dir}" ] || git clone "${upstream_repo_url}"

cd "${repo_dir}" || exit 1

git reset --hard &&\
  git pull --rebase && \
  cmake -DCMAKE_INSTALL_PREFIX="${prefix}" -S . -B build && \
  cmake --build build --target install --config Release && \
  rm -fr build

if ! grep -q "${profile_token}" "${profile_path}"
then
    printf "Prepending tool bin path %s to PATH by appending to profile %s" "${bin_path}" "${profile_path}"
    {
        printf "\n# -+- experimental %s infrastructure\n" "${tool}"
        printf "%s\n" "${profile_root}"
        printf "%s\n" "${profile_token}"
        printf "# -+-\n"
    } >> "${profile_path}"
    $SHELL
fi

printf "Testing the freshly build and deployed %s using the binary %s ...\n" "${tool}" "${bin_path}/${binary}"
which -a "${binary}"
"${binary}" --help
"${binary}" --version
file "$(which ${binary})"
stat "$(which ${binary})"
sha256sum "$(which ${binary})"
ssdeep "$(which ${binary})"
b3sum "$(which ${binary})"
