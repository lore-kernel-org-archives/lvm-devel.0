From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:07 +0000 (GMT)
Subject: dev-next - tests: avoid leaking unkilled commands
Message-ID: <20210322153907.161F93854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=583cf413d530927bccf2b7a11f3d5690edca4f8d
Commit:        583cf413d530927bccf2b7a11f3d5690edca4f8d
Parent:        fda7bc1297640d739067727b6165cde0613d1fe3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 00:44:45 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:59:50 2021 +0100

tests: avoid leaking unkilled commands

Between each new test here we want to kill previous commands,
otherwise they will influence results of next test.
---
 test/shell/pvmove-resume-multiseg.sh | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index a8e409f56..3a92dbaf3 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -78,6 +78,9 @@ test_pvmove_resume() {
 		aux prepare_clvmd
 	fi
 
+##	rm -f debug.log_DEBUG*
+#	lvs -ao+devices  $vg
+
 	# call resume function (see below)
 	# with expected number of spawned
 	# bg polling as parameter
@@ -153,7 +156,7 @@ pvmove_fg() {
 	aux enable_dev "$dev4"
 	aux enable_dev "$dev5"
 
-	pvmove
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove
 }
 
 pvmove_bg() {
@@ -198,8 +201,8 @@ pvmove_fg_single() {
 	aux enable_dev "$dev4"
 	aux enable_dev "$dev5"
 
-	pvmove "$dev1"
-	pvmove "$dev3"
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove "$dev1"
+	LVM_TEST_TAG="kill_me_$PREFIX" pvmove "$dev3"
 }
 
 pvmove_bg_single() {


