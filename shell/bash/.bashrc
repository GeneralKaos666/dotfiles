
# Flyline - enhanced Bash experience
enable flyline 2>/dev/null || enable -f "/data/data/com.termux/files/home/.local/lib/libflyline.so" flyline
export PATH="$HOME/zig-aarch64-linux-0.15.2:$PATH"
export PATH="$HOME/zig-aarch64-linux-0.15.2:$PATH"
export PATH="$HOME/zig-aarch64-linux-0.15.2:$PATH"
export PATH="$HOME/zig-aarch64-linux-0.15.2:$PATH"
export PATH="$HOME/zig-aarch64-linux-0.16.0:$PATH"

. "$HOME/.local/share/../bin/env"
corvene() { am start -a android.intent.action.VIEW -d "x-corvene://openLocalRepo$(realpath "${1:-.}" | sed 's/%/%25/g; s/ /%20/g')" > /dev/null; }
corvene-git-config() { am start -a android.intent.action.VIEW -d "x-corvene://importGitConfig/$(git config --global --list | base64 -w0 | tr '+/' '-_' | tr -d '=')" > /dev/null; }
[ -f "$PREFIX/etc/profile.d/flutter.sh" ] && source "$PREFIX/etc/profile.d/flutter.sh"

export ANDROID_USER_HOME="$HOME/.termux-adb"
export ANDROID_SDK_HOME="$HOME/.termux-adb"




# homebrew-termux
export PATH="/data/data/com.termux/files/home/brew/bin:$PATH"

# Flutter
[ -f "$PREFIX/etc/profile.d/flutter.sh" ] && source "$PREFIX/etc/profile.d/flutter.sh"


# Android SDK & Java
export ANDROID_HOME=$PREFIX/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin
if [ -z "${JAVA_HOME:-}" ] && [ -d "$PREFIX/lib/jvm" ]; then
    export JAVA_HOME=$(find "$PREFIX/lib/jvm" -maxdepth 1 -type d -name 'java-*-openjdk' 2>/dev/null | sort -V | tail -1)
fi
