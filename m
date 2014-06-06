From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:12 +0000 (UTC)
Subject: dev-prajnoha-report-select - tests: typo
Message-ID: <20140606120312.67E5560FA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c4e0c6127247c421e40d9d387ba89d8cd9899f5f
Commit:        c4e0c6127247c421e40d9d387ba89d8cd9899f5f
Parent:        54da0ea61afece94445754d3e0a8fd5e0964f1e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 2 09:38:10 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:49:35 2014 +0200

tests: typo

---
 test/shell/snapshot-usage.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 589ed43..fd43650 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -87,7 +87,7 @@ lvchange -an $vg1
 lvchange -ay $vg1
 check lv_field $vg1/$lv1 lv_active "$CHECK_ACTIVE"
 
-# Test removal of opened (bug unmounted) snapshot (device busy) for a while
+# Test removal of opened (but unmounted) snapshot (device busy) for a while
 sleep 120 < "$DM_DEV_DIR/$vg1/$lv1" &
 SLEEP_PID=$!
 


