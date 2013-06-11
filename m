From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:09:01 +0000 (UTC)
Subject: master - thin: report o as volume type for external origin
Message-ID: <20130611120901.D753D61018@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0290489c33be7d8318e3005dffcebc62a6f3354
Commit:        c0290489c33be7d8318e3005dffcebc62a6f3354
Parent:        7151ede767ad168b71f338c48835fcf64a9e3ce7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 5 13:45:31 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:02:41 2013 +0200

thin: report o as volume type for external origin

Reuse 'o' attr for lvs report also for external origin.
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 96478e6..c94c9e1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Report lvs volume type 'o' also for external origin volumes.
   Report lvs target type 't' only for thin pools and thin volumes.
   Fix test for active snapshot in cluster before resizing it.
   Report backtrace from dump filter error path.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e53fdf3..9cfc2fe 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -534,7 +534,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else if (lv->status & CONVERTING)
 		repstr[0] = 'c';
 	/* Origin takes precedence over mirror and thin volume */
-	else if (lv_is_origin(lv))
+	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
 	else if (lv->status & RAID)
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'R' : 'r';


