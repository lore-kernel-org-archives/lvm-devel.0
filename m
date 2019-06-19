From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 19 Jun 2019 07:42:05 -0400
Subject: stable-2.02 - tests: replaces grep -q usage
Message-ID: <201906191142.x5JBg5L0017374@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e80ca65d305cd896b98f1023e22c2ec9b4d4e5b5
Commit:        e80ca65d305cd896b98f1023e22c2ec9b4d4e5b5
Parent:        d6bce036155ae973c869bdce3ca5f824f933f599
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 17 22:47:35 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 19 13:36:58 2019 +0200

tests: replaces grep -q usage

Since we use 'set -euE -o pipefail' for shell execution,
any failure of any command in the 'piped' shell can result
in failure of whole executed chain - resulting in typically
unsually test skip, that was left unnoticed.

Since checked command have usually short output, the simplest
fix seems to be to let grep parse whole output instead
of quiting after first match.
---
 test/lib/aux.sh |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3a66f53..86ed554 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -26,7 +26,7 @@ expect_failure() {
 check_daemon_in_builddir() {
 	# skip if we don't have our own deamon...
 	if test -z "${installed_testsuite+varset}"; then
-		(which "$1" 2>/dev/null | grep -q "$abs_builddir") || skip "$1 is not in executed path."
+		(which "$1" 2>/dev/null | grep "$abs_builddir" >/dev/null ) || skip "$1 is not in executed path."
 	fi
 	rm -f debug.log strace.log
 }
@@ -167,7 +167,7 @@ prepare_clvmd() {
 
 	test -e "$DM_DEV_DIR/control" || dmsetup table >/dev/null # create control node
 	# skip if singlenode is not compiled in
-	(clvmd --help 2>&1 | grep "Available cluster managers" | grep -q "singlenode") || \
+	(clvmd --help 2>&1 | grep "Available cluster managers" | grep "singlenode" >/dev/null) || \
 		skip "Compiled clvmd does not support singlenode for testing."
 
 #	lvmconf "activation/monitoring = 1"
@@ -588,7 +588,7 @@ teardown() {
 	dm_table | not grep -E -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
 		cfg=$(test -s LOCAL_DMEVENTD || echo "--config activation{monitoring=0}")
-		if dm_info suspended,name | grep -q "^Suspended:.*$PREFIX" ; then
+		if dm_info suspended,name | grep "^Suspended:.*$PREFIX" >/dev/null ; then
 			echo "## skipping vgremove, suspended devices detected."
 		else
 			vgremove -ff "$cfg"  \
@@ -719,7 +719,7 @@ prepare_scsi_debug_dev() {
 
 	# Skip test if scsi_debug module is unavailable or is already in use
 	modprobe --dry-run scsi_debug || skip
-	lsmod | not grep -q scsi_debug || skip
+	lsmod | not grep scsi_debug >/dev/null || skip
 
 	# Create the scsi_debug device and determine the new scsi device's name
 	# NOTE: it will _never_ make sense to pass num_tgts param;
@@ -1534,7 +1534,7 @@ driver_at_least() {
 }
 
 have_thin() {
-	lvm segtypes 2>/dev/null | grep -q thin$ || {
+	lvm segtypes 2>/dev/null | grep thin$ >/dev/null || {
 		echo "Thin is not built-in." >&2
 		return 1
 	}
@@ -1578,7 +1578,7 @@ have_raid4 () {
 }
 
 have_cache() {
-	lvm segtypes 2>/dev/null | grep -q cache$ || {
+	lvm segtypes 2>/dev/null | grep cache$ >/dev/null || {
 		echo "Cache is not built-in." >&2
 		return 1
 	}


