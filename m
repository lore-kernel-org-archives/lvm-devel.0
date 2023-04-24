From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 24 Apr 2023 22:14:32 +0000 (GMT)
Subject: main - aux: more efficient lvmlock shutdown
Message-ID: <20230424221432.CD36F3858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e4c0701d9d37eaa46468319c4df8f221acd38b3
Commit:        5e4c0701d9d37eaa46468319c4df8f221acd38b3
Parent:        8947964f10499cf286985da37973cdbcaff9d7f1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 24 22:18:57 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 00:12:31 2023 +0200

aux: more efficient lvmlock shutdown

---
 test/lib/aux.sh | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a385df76b..8b04e1d30 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -175,7 +175,7 @@ prepare_lvmlockd() {
 	fi
 
 	sleep 1
-	if ! pgrep lvmlockd; then
+	if ! pgrep lvmlockd >LOCAL_LVMLOCKD; then
 		echo "Failed to start lvmlockd"
 		exit 1
 	fi
@@ -552,11 +552,7 @@ teardown() {
 	if test -n "$LVM_TEST_LVMLOCKD_TEST" ; then
 		echo ""
 		echo "## stopping lvmlockd in teardown"
-		killall lvmlockd
-		sleep 1
-		killall lvmlockd || true
-		sleep 1
-		killall -9 lvmlockd || true
+		kill_sleep_kill_ LOCAL_LVMLOCKD 0
 	fi
 
 	dm_table | not grep -E -q "$vg|$vg1|$vg2|$vg3|$vg4" || {

