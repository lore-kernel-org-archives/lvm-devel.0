From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 May 2015 08:21:24 +0000 (UTC)
Subject: master - tests: wait for scsi device to appear
Message-ID: <20150504082124.AE20560F2F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b09ac72624031a7d6d0b6416a067aa60584e0d6c
Commit:        b09ac72624031a7d6d0b6416a067aa60584e0d6c
Parent:        75aa3e951f2e22a790fe2425f3b3ef71f292be2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 4 10:14:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 4 10:14:52 2015 +0200

tests: wait for scsi device to appear

Continue with test as soon as device appear (avoid 2s delay)
---
 test/lib/aux.sh |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c01fb80..d0a5173 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -48,7 +48,7 @@ prepare_clvmd() {
 	LVM_LOG_FILE_EPOCH=CLVMD LVM_BINARY=$(which lvm) $run_valgrind clvmd -Isinglenode -d 1 -f &
 	echo $! > LOCAL_CLVMD
 
-	for i in $(seq 1 100) ; do
+	for i in {1..100} ; do
 		test $i -eq 100 && die "Startup of clvmd is too slow."
 		test -e "$CLVMD_PIDFILE" && break
 		sleep .2
@@ -74,7 +74,7 @@ prepare_dmeventd() {
 	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead
-	for i in $(seq 1 100) ; do
+	for i in {1..100} ; do
 		test $i -eq 100 && die "Startup of dmeventd is too slow."
 		test -e "${DMEVENTD_PIDFILE}" && break
 		sleep .2
@@ -369,6 +369,7 @@ prepare_loop() {
 prepare_scsi_debug_dev() {
 	local DEV_SIZE=$1
 	local SCSI_DEBUG_PARAMS=${@:2}
+	local DEBUG_DEV
 
 	rm -f debug.log strace.log
 	test ! -f "SCSI_DEBUG_DEV" || return 0
@@ -384,9 +385,12 @@ prepare_scsi_debug_dev() {
 	# last param wins.. so num_tgts=1 is imposed
 	touch SCSI_DEBUG_DEV
 	modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || skip
-	sleep 2 # allow for async Linux SCSI device registration
-
-	local DEBUG_DEV="/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)"
+	
+	for i in {1..20} ; do
+		DEBUG_DEV="/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)"
+		test -b "$DEBUG_DEV" && break
+		sleep .1 # allow for async Linux SCSI device registration
+        done
 	test -b "$DEBUG_DEV" || return 1 # should not happen
 
 	# Create symlink to scsi_debug device in $DM_DEV_DIR


