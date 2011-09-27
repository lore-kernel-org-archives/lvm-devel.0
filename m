From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:17 +0200
Subject: [PATCH 03/16] fsadm: Add simple configuration file
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-4-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |   32 +++++++++++++++++++++++++++++++-
 1 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index e982b88..bc8e91f 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -88,6 +88,9 @@ PROCDEVICES="/proc/devices"
 PROCPARTITIONS="/proc/partitions"
 NULL="$DM_DEV_DIR/null"
 
+CONFIG_PATHS="/etc/fsadm.conf ~/fsadm.conf"
+CONFIG=
+
 MAX_VGS=999
 
 # without bash $'\n'
@@ -1272,6 +1275,22 @@ check() {
 	esac
 }
 
+set_default_config() {
+	[ -z "$DEFAULT_DEVICE_POOL" ] && DEFAULT_DEVICE_POOL="device_pool"
+	[ -z "$LVOL_PREFIX" ] && LVOL_PREFIX="lvol"
+}
+
+parse_config() {
+	for line in $(cat "$1"); do
+		case "$line" in
+		  "DEFAULT_DEVICE_POOL"*) DEFAULT_DEVICE_POOL=${line##*=} ;;
+		  "LVOL_PREFIX"*) LVOL_PREFIX=${line##*=} ;;
+		  "#"*) continue ;;
+		  *) error "Unknown value \"$line\" in configuration file"
+		esac
+	done
+}
+
 #############################
 # start point of this script
 # - parsing parameters
@@ -1312,6 +1331,7 @@ do
 	  "-o"|"--resize-fs-only") RESIZE_FS_ONLY=1 ;;
 	  "-y"|"--yes") YES="-y" ;;
 	  "-l"|"--lvresize") ;;
+	  "-c"|"--config") CONFIG=$2; shift 1 ;;
 	  "check") COMMAND=$1; shift; ARGS="$@"; break ;;
 	  "resize") COMMAND=$1; shift; ARGS="$@"; break ;;
 	  "create") COMMAND=$1; shift; ARGS="$@"; break ;;
@@ -1327,6 +1347,16 @@ if [ -z "$COMMAND" ]; then
 	error "Missing command. (see: $TOOL --help)"
 fi
 
+set_default_config
+if [ "$CONFIG" ]; then
+	[ ! -f "$CONFIG" ] && error "\"$CONFIG\" is not proper configuration file"
+	CONFIG_PATHS+=" $CONFIG"
+fi
+for i in "$CONFIG_PATHS"; do
+	[ ! -f "$i" ] && continue
+	parse_config "$i"
+done
+
 export FSADM_RUNNING="fsadm"
-"$COMMAND $ARGS
+$COMMAND $ARGS
 cleanup 0
-- 
1.7.4.4


