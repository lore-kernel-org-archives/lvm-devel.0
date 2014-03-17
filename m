From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 15:34:12 +0000 (UTC)
Subject: master - tests: quotes for LVM_TEST vars
Message-ID: <20140317153412.E8B2E60E59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19fd6040c246b73dcdf8f522231e32e5889d4238
Commit:        19fd6040c246b73dcdf8f522231e32e5889d4238
Parent:        e3d208f7c2aa3964ae76a7fc108bf63957ef4bd6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 16:32:29 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 16:32:29 2014 +0100

tests: quotes for LVM_TEST vars

---
 test/lib/aux.sh   |    6 +++---
 test/lib/utils.sh |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 12e8e04..65eb1e7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -180,7 +180,7 @@ teardown_devs() {
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then
-		test ${LVM_TEST_PARALLEL:-0} -eq 1 || modprobe -r scsi_debug
+		test "${LVM_TEST_PARALLEL:-0}" -eq 1 || modprobe -r scsi_debug
 	else
 		test ! -f LOOP || losetup -d $(cat LOOP) || true
 		test ! -f LOOPFILE || rm -f $(cat LOOPFILE)
@@ -189,7 +189,7 @@ teardown_devs() {
 	rm -f LOOP
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
-	test ${LVM_TEST_PARALLEL:-0} -eq 1 -o -z "$COMMON_PREFIX" || {
+	test "${LVM_TEST_PARALLEL:-0}" -eq 1 -o -z "$COMMON_PREFIX" || {
 		teardown_devs_prefixed "$COMMON_PREFIX" 1
 		local stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) )
 		test ${#stray_loops[@]} -eq 0 || {
@@ -239,7 +239,7 @@ teardown() {
 
 	echo "ok"
 
-	test ${LVM_TEST_PARALLEL:-0} -eq 1 -o -n "$RUNNING_DMEVENTD" || not pgrep dmeventd #&>/dev/null
+	test "${LVM_TEST_PARALLEL:-0}" -eq 1 -o -n "$RUNNING_DMEVENTD" || not pgrep dmeventd #&>/dev/null
 }
 
 prepare_loop() {
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 819a0eb..b2e82aa 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -110,7 +110,7 @@ STACKTRACE() {
 		i=$(($i + 1))
 	done
 
-	test ${LVM_TEST_PARALLEL:-0} -eq 1 -o -n "$RUNNING_DMEVENTD" -o -f LOCAL_DMEVENTD || {
+	test "${LVM_TEST_PARALLEL:-0}" -eq 1 -o -n "$RUNNING_DMEVENTD" -o -f LOCAL_DMEVENTD || {
 		pgrep dmeventd &>/dev/null && \
 			die "** During test dmeventd has been started!"
 	}


