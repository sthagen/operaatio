#! /usr/bin/env bash
# Deploy clang compiled from source
tool="clang"
binary="clang"
server_url="https://github.com"
provider_org="sthagen"
repo_dir="llvm-llvm-project"
upstream_repo_url="${server_url}/${provider_org}/${repo_dir}"
prefix="/opt/${tool}"
bin_path="${prefix}/bin"
lib_path="${prefix}/lib"
src_path="${prefix}/src"
profile_path="${HOME}"/.bashrc
profile_root="export OPENEXR_ROOT=/opt/${tool}"
profile_token="export PATH=${bin_path}:\$PATH"

sudo mkdir -p "${prefix}" && sudo chown "${USER}":"${USER}" "${prefix}" || exit 1
sudo mkdir -p "${src_path}" && sudo chown "${USER}":"${USER}" "${src_path}" && cd "${src_path}"  || exit 1

[ -d "${src_path}/${repo_dir}" ] || git clone --depth=1 "${upstream_repo_url}" && git fetch --unshallow

cd "${src_path}/${repo_dir}" || exit 1

target_triple="$(gcc -dumpmachine)"
# x86_64-pc-linux-gnu

git reset --hard &&\
  git pull --rebase && \
  cmake -DCMAKE_INSTALL_PREFIX="${prefix}" \
    -DLLVM_ENABLE_PROJECTS="clang;lldb" \
    -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
    -DLLVM_RUNTIME_TARGETS="${target_triple}" \
    -DCMAKE_BUILD_TYPE=Release \
    -G "Unix Makefiles" -S llvm -B build && \
  cmake --build build --target runtimes --config Release && \
  cmake --build build --target check-runtimes --config Release && \
  cmake --build build --target install-runtimes --config Release && \
  cmake --build build --target install --config Release && \
  echo "until here ok ----- kind of -----" && \
  rm -fr build

printf "Testing the freshly build and deployed %s using the binary %s ...\n" "${tool}" "${bin_path}/${binary}"
which -a "${binary}"
"${binary}" --help
"${binary}" --version
file "$(which ${binary})"
stat "$(which ${binary})"
sha256sum "$(which ${binary})"
ssdeep "$(which ${binary})"
b3sum "$(which ${binary})"

