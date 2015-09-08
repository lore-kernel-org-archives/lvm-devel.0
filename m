From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Sep 2015 13:41:43 +0000 (UTC)
Subject: master - tests: ensure dd flushed all data before exit
Message-ID: <20150908134143.752B0605B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=587fd6a0e479f630ad4d574d391f269048a81186
Commit:        587fd6a0e479f630ad4d574d391f269048a81186
Parent:        6cb7f21e385178a7928635fc9531e2f6d8a91aac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 8 14:11:46 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 15:41:34 2015 +0200

tests: ensure dd flushed all data before exit

---
 test/shell/select-report.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index cd3f452..fde7dc0 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -60,7 +60,7 @@ sel() {
 	items_found=$(wc -l "$OUT_LOG_FILE" | cut -f 1 -d ' ')
 
 	# the number of lines on output must match
-	test $items_found -eq $# || {
+	test "$items_found" -eq $# || {
 		echo "  >>> NUMBER OF ITEMS EXPECTED: $# ($@)"
 		echo "  >>> NUMBER OF ITEMS FOUND: $items_found ($(< $OUT_LOG_FILE))"
 		return 1
@@ -143,10 +143,11 @@ if aux target_at_least dm-snapshot 1 10 0; then
 	# Before 1.10.0, the snap percent included metadata size.
 	sel lv 'snap_percent=0' snap
 fi
-dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=1
+dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=1 conv=fdatasync
 sel lv 'snap_percent<50' snap
 sel lv 'snap_percent>50'
-dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=4
+# overflow snapshot -> invalidated, but still showing 100%
+not dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=4 conv=fdatasync
 sel lv 'snap_percent=100' snap
 # % char is accepted as suffix for percent values
 sel lv 'snap_percent=100%' snap


