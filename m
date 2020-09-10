From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 10 Sep 2020 21:56:19 +0000 (GMT)
Subject: master - debug: drop debug trace from regular path
Message-ID: <20200910215619.163C73985446@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7bd3ba22dc6736654bbfe235924a64a511bcf8d
Commit:        e7bd3ba22dc6736654bbfe235924a64a511bcf8d
Parent:        bc0980362895ab64fb9f11811dc72937fe92c8a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 23:33:46 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 23:55:03 2020 +0200

debug: drop debug trace from regular path

Since we query on regular code these:
  lv_raid_has_integrity()
  lv_has_integrity_recalculate_metadata()
without prior checking for lv_is_raid() - these 'return 0' should
not use <stacktrace> as they are expected.
---
 lib/metadata/integrity_manip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index ddcce9886..42e6d936e 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -828,7 +828,7 @@ int lv_has_integrity_recalculate_metadata(struct logical_volume *lv)
 	int ret = 0;
 
 	if (!lv_is_raid(lv) && !lv_is_integrity(lv))
-		return_0;
+		return 0;
 
 	seg = first_seg(lv);
 
@@ -856,7 +856,7 @@ int lv_raid_has_integrity(struct logical_volume *lv)
 	uint32_t s;
 
 	if (!lv_is_raid(lv))
-		return_0;
+		return 0;
 
 	seg = first_seg(lv);
 


