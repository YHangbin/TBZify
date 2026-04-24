#!/bin/bash
# Modified by Antigravity (Pair Programming with Hangbin)
# Source: https://github.com/YHangbin/TBZify

git="https://github.com/jetfir3/TBZify"
json_url="https://raw.githubusercontent.com/LoaderSpot/table/main/table/versions.json"

clear="\033[0m"
red="\033[0;31m"
yellow="\033[0;33m"

showHelp () {
  echo -e \
"Options:
-a [path]    : set custom path to Spotify.app
-b           : block Spotify auto-updates (--blockupdates)
-d           : download only, no install (--noinstall)
--datawipe   : delete app data only
-h           : print this message (--help)
-p [path]    : set archive/download path
-s           : save archive after script finishes (--save)
-u [URL]     : URL of archive to download/install
--uninstall  : uninstall Spotify, including app data
-v [version] : archive version to download/install\n"
}

while getopts ':a:bdhsp:u:v:-:' flag; do
  case "${flag}" in
    -)
      case "${OPTARG}" in
        blockupdates) updatesVar="true" ;;
        datawipe) appDataVar="true" ;;
        help) showHelp; exit 0 ;;
        noinstall) downloadOnlyVar="true" ;;
        save) saveVar="true" ;;
        uninstall) uninstallVar="true" ;;
        *) echo -e "${red}Error:${clear} '--""${OPTARG}""' not supported\n\n$(showHelp)\n" >&2; exit 1 ;;
      esac ;;
    a) a="${OPTARG}"; appPath="${a}" ;;
    b) updatesVar="true" ;;
    d) downloadOnlyVar="true" ;;
    h) showHelp; exit 0 ;;
    s) saveVar="true" ;;
    p) p="${OPTARG}"; pathVar="${p}" ;;
    u) u="${OPTARG}"; urlVar="${u}" ;;
    v) [[ "${OPTARG}" =~ ^[1].*$ ]] && { v="${OPTARG}"; versionVar="${v}"; } ;;
    \?) echo -e "${red}Error:${clear} '-""${OPTARG}""' not supported\n\n$(showHelp)" >&2; exit 1 ;;
    :) echo -e "${red}Error:${clear} '-""${OPTARG}""' requires additional argument\n\n$(showHelp)" >&2; exit 1 ;;
  esac
done

[[ -z "${appDataVar}" && -z "${pathVar+x}" && -z "${uninstallVar+x}" && -z "${urlVar+x}" && -z "${versionVar+x}" ]] && { echo -e "${red}Required option(s) not set.${clear}\n" >&2; exit 1; }
[[ -z "${appPath+x}" ]] && { [[ -d "${HOME}/Applications/Spotify.app" ]] && appPath="${HOME}/Applications" || appPath="/Applications"; }; appPathVar="${appPath}/Spotify.app"

if [[ "${uninstallVar}" || "${appDataVar}" ]]; then
  [[ "${uninstallVar}" ]] && echo "Uninstalling Spotify..." || echo "Deleting app data..."
  command pgrep [sS]potify >/dev/null && osascript -e 'quit app "Spotify"'
  [[ "${uninstallVar}" ]] && { [[ -d "${appPathVar}" ]] && rm -rf "${appPathVar}" 2>/dev/null || echo -e "${yellow}${appPathVar} not found but continuing removal of app data...${clear}"; }
  chflags -R nouchg "$HOME/Library/Application Support/Spotify" 2>/dev/null
  rm -rf "$HOME/Library/Application Support/Spotify" 2>/dev/null
  rm -rf "$HOME"/Library/*/com.spotify* 2>/dev/null
  rm -rf /private/var/folders/*/*/*/*om.spotify* 2>/dev/null
  [[ -z "${urlVar+x}" && -z "${versionVar+x}" && -z "${pathVar+x}" ]] && { echo -e "Finished!\n"; exit 0; }
fi

if [[ -z "${urlVar+x}" && -z "${versionVar+x}" ]]; then
  [[ ! -f "${pathVar}" ]] && { echo -e "${red}Archive not found!${clear}\n" >&2; exit 1; }
  fileVar="$(echo "${pathVar}" | perl -ne '/^.*\/(.*)/ && print "$1"')"
  pathVar="$(echo "${pathVar}" | perl -ne '/(.*)\/.*/ && print "$1"')"
  noDownload="true"
elif [[ "${versionVar}" ]]; then
  # 自动识别架构：Apple Silicon 对应 arm64, Intel 对应 intel
  [[ $(sysctl -n machdep.cpu.brand_string) =~ "Apple" ]] && archVar="arm64" || archVar="intel"
  echo "Checking version $versionVar ($archVar) from database..."
  
  # 使用 perl (macOS 自带) 解析 JSON 获取 URL
  urlVar=$(curl -sL "$json_url" | perl -MJSON::PP -e '
    my ($v, $a) = @ARGV;
    my $json = do { local $/; <STDIN> };
    my $data = decode_json($json);
    if (exists $data->{$v} && exists $data->{$v}{mac}{$a}) {
      print $data->{$v}{mac}{$a}{url};
    }
  ' "$versionVar" "$archVar")

  if [[ -z "$urlVar" ]]; then
    echo -e "${red}Error:${clear} Version $versionVar for $archVar not found in database." >&2; exit 1
  fi
fi

if [[ -z "${noDownload+x}" ]]; then
  # 提取文件名
  fileVar=$(echo "${urlVar}" | perl -ne '/\/([^\/]+)$/ && print "$1"')
  [[ -z "${fileVar}" ]] && fileVar="spotify-archive.tbz"
  
  [[ -z "${pathVar+x}" ]] && pathVar="${HOME}/Downloads"
  [[ ! -d "${pathVar}" ]] && mkdir -p "${pathVar}"
  
  echo -e "Downloading to ${yellow}${pathVar}/${fileVar}${clear}..."
  curl -q --progress-bar -f -o "${pathVar}/${fileVar}" "$urlVar" || { echo -e "${red}Download failed.${clear} Exiting...\n" >&2; exit 1; }
fi

if [[ -z "${downloadOnlyVar+x}" ]]; then
  echo -e "Installing to ${yellow}${appPathVar}${clear}..."
  command pgrep [sS]potify >/dev/null && osascript -e 'quit app "Spotify"'
  mkdir -p "${appPathVar}/tmpSpot"

  tar -xpf "${pathVar}/${fileVar}" -C "${appPathVar}/tmpSpot" --strip-components=1 || { echo -e "${red}Install failed.${clear} Exiting...\n" >&2; rm -rf "${appPathVar}/tmpSpot"; exit 1; }
  rm -rf "${appPathVar}/Contents" 2>/dev/null
  mv "${appPathVar}/tmpSpot" "${appPathVar}/Contents" 2>/dev/null
fi

if [[ "${updatesVar}" ]]; then
  updatesPathVar="${HOME}/Library/Application Support/Spotify/PersistentCache/Update"
  [[ -d "${updatesPathVar}" ]] || mkdir -p "${updatesPathVar}"
  [[ -f "${updatesPathVar}/BLOCKED" ]] || { echo "Blocking auto-updates..."; rm -f "${updatesPathVar}/"* 2>/dev/null; touch "${updatesPathVar}/BLOCKED" 2>/dev/null; chflags uchg "${updatesPathVar}"; }
fi

[[ "${downloadOnlyVar}" || "${saveVar}" ]] || { echo -e "Deleting ${yellow}${pathVar}/${fileVar}${clear}..."; rm -f "${pathVar}/${fileVar}" 2>/dev/null; }
echo -e "Finished!\n"
exit 0
