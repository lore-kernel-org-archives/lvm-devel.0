From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:09:03 +0000 (UTC)
Subject: master - thin: report 'e' metadata type with higher priority
Message-ID: <20130611120903.EACBE61018@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01ef97fcbbfe0ed49b3dc61765d166efe8647e8a
Commit:        01ef97fcbbfe0ed49b3dc61765d166efe8647e8a
Parent:        c0290489c33be7d8318e3005dffcebc62a6f3354
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 5 13:46:38 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:03:08 2013 +0200

thin: report 'e' metadata type with higher priority

Giving volume type information about being 'metadata' type of volume
has higher priority then i.e.  'mirror' or 'thin' flag - for those
type we have 'target attr' (7th. field).
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c94c9e1..f9f51dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Report lvs volume type 'e' with higher priority.
   Report lvs volume type 'o' also for external origin volumes.
   Report lvs target type 't' only for thin pools and thin volumes.
   Fix test for active snapshot in cluster before resizing it.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9cfc2fe..fb7870d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -536,6 +536,9 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	/* Origin takes precedence over mirror and thin volume */
 	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
+	else if (lv_is_thin_pool_metadata(lv) ||
+		 (lv->status & RAID_META))
+		repstr[0] = 'e';
 	else if (lv->status & RAID)
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'R' : 'r';
 	else if (lv->status & MIRRORED)
@@ -548,8 +551,6 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		repstr[0] = 't';
 	else if (lv_is_thin_pool_data(lv))
 		repstr[0] = 'T';
-	else if (lv_is_thin_pool_metadata(lv) || (lv->status & RAID_META))
-		repstr[0] = 'e';
 	else if (lv->status & MIRROR_IMAGE)
 		repstr[0] = (_lv_mimage_in_sync(lv)) ? 'i' : 'I';
 	else if (lv->status & RAID_IMAGE)


