From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:15 +0000 (GMT)
Subject: main - aux: retry brd removal
Message-ID: <20230506204615.66FFF3858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e8ede833ba4b974f7e2acf8c7e36eaba9661fe8
Commit:        6e8ede833ba4b974f7e2acf8c7e36eaba9661fe8
Parent:        87eae82195d5272808614b14843c302e7bed80d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 6 22:38:58 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 22:41:23 2023 +0200

aux: retry brd removal

Try to remove brd twice if there is some collision with udevd.
Instanciate only 1 ramdisk.
Use just 'eval' for '--nameprefixes' results.
---
 test/lib/aux.sh | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c6b6ac1cc..5a3f0fe44 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -418,9 +418,7 @@ teardown_devs_prefixed() {
 
 			for dm in $(dm_info name,open --separator ';'  --nameprefixes --unquoted --sort open,"$sortby" -S "name=~$prefix" --mangle none || true) ; do
 				test "$dm" != "No devices found" || break 2
-				DM_NAME=${dm##DM_NAME=}
-				DM_NAME=${DM_NAME%%;DM_OPEN*}
-				DM_OPEN=${dm##*;DM_OPEN=}
+				eval "$dm"
 				local force="-f"
 				if test "$i" = 0; then
 					if test "$once" = 1 ; then
@@ -452,17 +450,24 @@ teardown_devs() {
 
 	test ! -f MD_DEV || cleanup_md_dev
 	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
-	test ! -f RAMDISK || { modprobe -r brd || true ; }
+	if test -f RAMDISK ; then
+		for i in 1 2 ; do
+			modprobe -r brd && break
+			sleep .1
+			udev_wait
+		done
+	fi
 
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then
 		udev_wait
 		test "${LVM_TEST_PARALLEL:-0}" -eq 1 || {
-			if ! modprobe -r scsi_debug ; then
-				sleep 1
-				modprobe -r scsi_debug || true
-			fi
+			for i in 1 2 ; do
+				modprobe -r scsi_debug && break
+				sleep .1
+				udev_wait
+			done
 		}
 	else
 		test ! -f LOOP || losetup -d "$(< LOOP)" || true
@@ -684,7 +689,7 @@ prepare_ramdisk() {
 	modprobe -r brd || return 0
 
 	echo -n "## preparing ramdisk device..."
-	modprobe brd rd_size=$((size * 1024)) || return
+	modprobe brd rd_size=$((size * 1024)) rd_nr=1 || return
 
 	BACKING_DEV=/dev/ram0
 	echo "ok ($BACKING_DEV)"

