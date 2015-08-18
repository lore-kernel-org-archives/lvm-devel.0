From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:01:30 +0000 (UTC)
Subject: master - lvmcache: check for too long pvid
Message-ID: <20150818130130.902E260643@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70db1d523db330cbdfc39163c30dc00cf16a1fdc
Commit:        70db1d523db330cbdfc39163c30dc00cf16a1fdc
Parent:        8e229cb7ea37ccab0e235e53d27adca9b32ffae0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 11:28:02 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 14:53:36 2015 +0200

lvmcache: check for too long pvid

---
 lib/cache/lvmcache.c         |    7 ++++++-
 lib/format_text/text_label.c |    8 +++++---
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index cfa1d5f..530bcd3 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1178,7 +1178,12 @@ static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 		return 1;
 	if (*info->dev->pvid)
 		dm_hash_remove(_pvid_hash, info->dev->pvid);
-	strncpy(info->dev->pvid, pvid, sizeof(info->dev->pvid));
+
+	if (!dm_strncpy(info->dev->pvid, pvid, sizeof(info->dev->pvid))){
+		log_error("_lvmcache_update: too long pvid: %s.", pvid);
+		return 0;
+	}
+
 	if (!dm_hash_insert(_pvid_hash, pvid, info)) {
 		log_error("_lvmcache_update: pvid insertion failed: %s", pvid);
 		return 0;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 4ad2ccd..5835bc2 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -94,9 +94,11 @@ static int _text_write(struct label *label, void *buf)
 	 * PV header base
 	 */
 	/* FIXME Move to where label is created */
-	strncpy(label->type, LVM2_LABEL, sizeof(label->type));
-
-	strncpy((char *)lh->type, label->type, sizeof(label->type));
+	if (!dm_strncpy(label->type, LVM2_LABEL, sizeof(label->type)) ||
+	    !dm_strncpy((char *)lh->type, label->type, sizeof(label->type))) {
+		log_error(INTERNAL_ERROR "LVM2 label %s does not fit.", LVM2_LABEL);
+		return 0;
+	}
 
 	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 	info = (struct lvmcache_info *) label->info;


