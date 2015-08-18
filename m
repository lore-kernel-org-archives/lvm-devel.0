From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:23:27 +0000 (UTC)
Subject: master - Revert "lvmcache: check for too long pvid"
Message-ID: <20150818132327.13E0760048@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28b4fa3e270711e7f7ee45642b28a7c7127ea982
Commit:        28b4fa3e270711e7f7ee45642b28a7c7127ea982
Parent:        b19380998739b9971d27845a70a78511c2335cb0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 15:21:48 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 15:22:13 2015 +0200

Revert "lvmcache: check for too long pvid"

This reverts commit 70db1d523db330cbdfc39163c30dc00cf16a1fdc.
Since we use 'strncpy' even for case where it exactly matches
the buffer size and \0 is not expected to be added there.
---
 lib/cache/lvmcache.c         |    7 +------
 lib/format_text/text_label.c |    8 +++-----
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 530bcd3..cfa1d5f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1178,12 +1178,7 @@ static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 		return 1;
 	if (*info->dev->pvid)
 		dm_hash_remove(_pvid_hash, info->dev->pvid);
-
-	if (!dm_strncpy(info->dev->pvid, pvid, sizeof(info->dev->pvid))){
-		log_error("_lvmcache_update: too long pvid: %s.", pvid);
-		return 0;
-	}
-
+	strncpy(info->dev->pvid, pvid, sizeof(info->dev->pvid));
 	if (!dm_hash_insert(_pvid_hash, pvid, info)) {
 		log_error("_lvmcache_update: pvid insertion failed: %s", pvid);
 		return 0;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 5835bc2..4ad2ccd 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -94,11 +94,9 @@ static int _text_write(struct label *label, void *buf)
 	 * PV header base
 	 */
 	/* FIXME Move to where label is created */
-	if (!dm_strncpy(label->type, LVM2_LABEL, sizeof(label->type)) ||
-	    !dm_strncpy((char *)lh->type, label->type, sizeof(label->type))) {
-		log_error(INTERNAL_ERROR "LVM2 label %s does not fit.", LVM2_LABEL);
-		return 0;
-	}
+	strncpy(label->type, LVM2_LABEL, sizeof(label->type));
+
+	strncpy((char *)lh->type, label->type, sizeof(label->type));
 
 	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 	info = (struct lvmcache_info *) label->info;


