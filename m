From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 21 Sep 2017 11:17:22 -0400
Subject: master - blkdeactivate: fix --{dm, lvm, mpath}options option name recognition
Message-ID: <201709211517.v8LFHM3D021418@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9f34125d5d6f0755af8b99ec9ca04495cf8d8df6
Commit:        9f34125d5d6f0755af8b99ec9ca04495cf8d8df6
Parent:        0ab9e4b6a720972cffc8bc465f4d4c3d788d0820
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 21 17:03:42 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 21 17:08:44 2017 +0200

blkdeactivate: fix --{dm,lvm,mpath}options option name recognition

There was a typo in blkdeactivate --dmoption/--lvmoption/mpathoption,
it had missing "s" at the end and it was not recognized properly, only
short names for the options (-d/-l/-m).
---
 WHATS_NEW_DM                |    1 +
 man/blkdeactivate.8_main    |    6 +++---
 scripts/blkdeactivate.sh.in |   20 ++++++++++----------
 3 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2a351a4..2060ada 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.144 - 
 ======================================
+  Fix typo in blkdeactivate's '--{dm,lvm,mpath}options' option name.
   Correct return value testing when get reserved values for reporting.
   Take -S with dmsetup suspend/resume/clear/wipe_table/remove/deps/status/table.
 
diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index 9a0e84e..80235ca 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -22,7 +22,7 @@ based devices are handled using the \fBdmsetup\fP(8) command.
 MD devices are handled using the \fBmdadm\fP(8) command.
 .SH OPTIONS
 .TP
-.BR -d ", " --dmoption \ \fIdm_options\fP
+.BR -d ", " --dmoptions \ \fIdm_options\fP
 Comma separated list of device-mapper specific options.
 Accepted \fBdmsetup\fP(8) options are:
 .RS
@@ -41,7 +41,7 @@ the device was skipped.
 .BR -h ", " --help
 Display the help text.
 .TP
-.BR -l ", " --lvmoption \ \fIlvm_options\fP
+.BR -l ", " --lvmoptions \ \fIlvm_options\fP
 Comma-separated list of LVM specific options:
 .RS
 .IP \fIretry\fP
@@ -52,7 +52,7 @@ Deactivating the Volume Group as a whole is quicker than deactivating
 each Logical Volume separately.
 .RE
 .TP
-.BR -m ", " --mpathoption \ \fImpath_options\fP
+.BR -m ", " --mpathoptions \ \fImpath_options\fP
 Comma-separated list of device-mapper multipath specific options:
 .RS
 .IP \fIdisablequeueing\fP
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 969eace..61c7a86 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -113,13 +113,13 @@ usage() {
 	echo "      If devices are specified, deactivate only supplied devices and their holders."
 	echo
 	echo "  Options:"
-	echo "    -e | --errors                    Show errors reported from tools"
-	echo "    -h | --help                      Show this help message"
-	echo "    -d | --dmoption    DM_OPTIONS    Comma separated DM specific options"
-	echo "    -l | --lvmoption   LVM_OPTIONS   Comma separated LVM specific options"
-	echo "    -m | --mpathoption MPATH_OPTIONS Comma separated DM-multipath specific options"
-	echo "    -u | --umount                    Unmount the device if mounted"
-	echo "    -v | --verbose                   Verbose mode (also implies -e)"
+	echo "    -e | --errors                     Show errors reported from tools"
+	echo "    -h | --help                       Show this help message"
+	echo "    -d | --dmoptions    DM_OPTIONS    Comma separated DM specific options"
+	echo "    -l | --lvmoptions   LVM_OPTIONS   Comma separated LVM specific options"
+	echo "    -m | --mpathoptions MPATH_OPTIONS Comma separated DM-multipath specific options"
+	echo "    -u | --umount                     Unmount the device if mounted"
+	echo "    -v | --verbose                    Verbose mode (also implies -e)"
 	echo
 	echo "  Device specific options:"
 	echo "    DM_OPTIONS:"
@@ -490,9 +490,9 @@ while test $# -ne 0; do
 		"") ;;
 		"-e"|"--errors") ERRORS=1 ;;
 		"-h"|"--help") usage ;;
-		"-d"|"--dmoption ") get_dmopts "$2" ; shift ;;
-		"-l"|"--lvmoption ") get_lvmopts "$2" ; shift ;;
-		"-m"|"--mpathoption ") get_mpathopts "$2" ; shift ;;
+		"-d"|"--dmoptions") get_dmopts "$2" ; shift ;;
+		"-l"|"--lvmoptions") get_lvmopts "$2" ; shift ;;
+		"-m"|"--mpathoptions") get_mpathopts "$2" ; shift ;;
 		"-u"|"--umount") DO_UMOUNT=1 ;;
 		"-v"|"--verbose") VERBOSE=1 ; ERRORS=1 ;;
 		"-vv") VERBOSE=1 ; ERRORS=1 ; set -x ;;


