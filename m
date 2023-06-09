From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jun 2023 16:02:00 +0000 (GMT)
Subject: main - tests: vdo manager wrapper tool updates
Message-ID: <20230609160200.5168D3858C41@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f661a24c4f7fa8f161f17da093e456f0d60e106
Commit:        7f661a24c4f7fa8f161f17da093e456f0d60e106
Parent:        734d9791f817693f1d6f396b34d105894aacb16c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 13:24:56 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 18:01:16 2023 +0200

tests: vdo manager wrapper tool updates

Support size specification in KiB units.
Add some theoretical support for some new options from vdoprepareforlvm.
---
 test/lib/lvm_vdo_wrapper.sh | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/test/lib/lvm_vdo_wrapper.sh b/test/lib/lvm_vdo_wrapper.sh
index bcc3781f7..83332561a 100755
--- a/test/lib/lvm_vdo_wrapper.sh
+++ b/test/lib/lvm_vdo_wrapper.sh
@@ -11,7 +11,7 @@ LVM_VDO_FORMAT=${LVM_VDO_FORMAT-"oldvdoformat"}
 # tool for shifting VDO metadata header by 2MiB
 LVM_VDO_PREPARE=${LVM_VDO_PREPARE-"oldvdoprepareforlvm"}
 # default vdo conf file
-LVM_VDO_DEFAULT_CONF=${LVM_VDO_DEFAULT_CONF-"/tmp/vdoconf.yml"}
+LVM_VDO_DEFAULT_CONF=${LVM_VDO_DEFAULT_CONF-"${TMPDIR:-/tmp}/vdoconf.yml"}
 
 vdo_die_() {
 	echo -e "$@" >&2
@@ -39,6 +39,7 @@ vdo_get_kb_size_with_unit_() {
 	esac
 
 	case "$1" in
+	  *[kK]) sz=1 ;;
 	  *[mM]) sz=1024 ;;
 	  *[gG]) sz=$(( 1024 * 1024 )) ;;
 	  *[tT]) sz=$(( 1024 * 1024 * 1024 )) ;;
@@ -320,6 +321,10 @@ local vdo_force=
 local vdo_name=
 local vdo_verbose=
 local vdo_device=
+local vdo_dry_run=
+local vdo_check=
+local vdo_version=
+local vdo_help=
 
 while [ "$#" -ne 0 ]
 do
@@ -328,6 +333,10 @@ do
 	  "--name"|"-n") shift; vdo_name=$1 ;;
 	  "--verbose"|"-d"|"--debug") vdo_verbose="-v" ;;
 	  "--force") vdo_force="--force" ;;
+	  "--dry-run") vdo_dry_run="--dry-run" ;;
+	  "--check") vdo_check="--check" ;;
+	  "--version") vdo_version="--version" ;;
+	  "--help") vdo_help="--help" ;;
 	esac
 	shift
 done
@@ -339,7 +348,7 @@ vdo_device=$(awk -v vdovolname="$vdo_name" 'BEGIN { have=0 }
      "$vdo_confFile")
 
 #dmsetup status --target vdo "$vdo_name" || true
-vdo_dry_ "$LVM_VDO_PREPARE" "$vdo_device"
+vdo_dry_ "$LVM_VDO_PREPARE" $vdo_dry_run $vdo_check $vdo_version $vdo_help "$vdo_device"
 vdo_dry_ vdo_remove_ -f "$vdo_confFile" -n "$vdo_name" || true
 }
 

