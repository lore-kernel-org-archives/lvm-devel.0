From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jul 2021 14:38:19 +0000 (GMT)
Subject: main - vgmerge: remove one of merge pmspare LVs
Message-ID: <20210723143819.56CCA3853C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cbc9e8296752df35626a9b50de1cb551ff5e99e
Commit:        9cbc9e8296752df35626a9b50de1cb551ff5e99e
Parent:        06602942a31d82cb69e9d1874f3b63825c0f93ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 23 16:31:11 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 23 16:35:47 2021 +0200

vgmerge: remove one of merge pmspare LVs

When merging 2 VG, where both of them have pmspare volume,
select the bigger one and remove the other.
---
 tools/vgmerge.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 895018a6f..884ad4b8d 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -92,6 +92,20 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		}
 	}
 
+	if (vg_from->pool_metadata_spare_lv &&
+	    vg_to->pool_metadata_spare_lv) {
+		if (vg_from->pool_metadata_spare_lv->le_count >
+		    vg_to->pool_metadata_spare_lv->le_count)
+			/* Preserve bigger pmspare from  VG_FROM */
+			lv = vg_to->pool_metadata_spare_lv;
+		else
+			lv = vg_from->pool_metadata_spare_lv;
+
+		log_debug_metadata("Removing pool metadata spare %s.", display_lvname(lv));
+		if (!lv_remove_single(cmd, lv, DONT_PROMPT, 0))
+				return_ECMD_FAILED;
+	}
+
 	if (!vgs_are_compatible(cmd, vg_from, vg_to))
 		goto_bad;
 


