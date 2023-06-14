#! /usr/bin/env bash
# Deploy lcov compiled from source
tool="lcov"
binary="${tool}"
server_url="https://github.com"
provider_org="sthagen"
repo_dir="linux-test-project-${tool}"
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

git pull --rebase && \
  make PREFIX="${prefix}" install

if ! grep -q "${profile_token}" "${profile_path}"
then
    printf "Prepending tool bin path %s to PATH by appending to profile %s" "${bin_path}" "${profile_path}"
    {
        printf "\n# -+- experimental lcov infrastructure\n"
        printf "%s\n" "${profile_token}"
        printf "# -+-\n"
    } >> "${profile_path}"
    $SHELL
fi

printf "Testing the freshly build and deployed %s using the binary %s ...\n" "${tool}" "${bin_path}/${binary}"
which "${binary}"
"${binary}" --help
"${binary}" --version

if perl -MDateTime -e 1 && perl -MCapture::Tiny -e 1
then
    printf "Good, perl DateTime and Capture::Tiny modules available\n"
else
    printf "Post work needed: Make sure that the perl DateTime and Capture::Tiny modules are available\n"
    printf "You can install them per:\n"
    printf "    sudo cpan Capture::Tiny\n"
    printf "    sudo cpan DateTime\n"
    printf "This will take seom time (esp. the DateTime install) but it is a one off operation\n"
fi
