From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 21:42:20 +0000 (GMT)
Subject: main - cov: avoid using NULL info
Message-ID: <20211015214220.8E80D3858405@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2779830a060730801ae6b055c2332301bf913c0f
Commit:        2779830a060730801ae6b055c2332301bf913c0f
Parent:        8aefd97252ab5cde9811d93138239f3defeee73b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 14:42:10 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 23:36:22 2021 +0200

cov: avoid using NULL info

Check lvmcache info exists before calling lvmcache_del_save_bad_mda().
---
 lib/format_text/format-text.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 941a34944..00443faa1 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -465,7 +465,7 @@ static struct volume_group *_vg_read_raw(struct cmd_context *cmd,
 
 	vg = _vg_read_raw_area(cmd, fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, mda_is_primary(mda));
 
-	if (!vg && !*use_previous_vg) {
+	if (!vg && use_previous_vg && !*use_previous_vg) {
 		/*
 		 * This condition (corrupt metadata text) is often seen in the
 		 * label_scan()/_text_read() phase, where this code corresponds to
@@ -477,8 +477,12 @@ static struct volume_group *_vg_read_raw(struct cmd_context *cmd,
 		struct lvmcache_info *info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
 		log_warn("WARNING: reading %s mda%d failed to read metadata.", dev_name(dev), mda_is_primary(mda)?1:2);
 		log_warn("WARNING: repair VG metadata on %s with vgck --updatemetadata.", dev_name(dev));
-		/* remove mda from lvmcache, saving it in info->bad_mdas for possible repair with updatemetadata */
-		lvmcache_del_save_bad_mda(info, mda->mda_num, BAD_MDA_TEXT);
+		if (info)
+			/* remove mda from lvmcache, saving it in info->bad_mdas for possible repair with updatemetadata */
+			lvmcache_del_save_bad_mda(info, mda->mda_num, BAD_MDA_TEXT);
+		else
+			log_warn("WARNING: No cache info for %s", dev_name(dev));
+
 		/* remove mda from fid */
 		fid_remove_mda(fid, mda, NULL, 0, 0);
 	}


