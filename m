From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:48 +0000 (UTC)
Subject: master - thin: merge display
Message-ID: <20131204133148.0F82760FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff112eee181748dbf827d91a7ebf0c0f1d7878a0
Commit:        ff112eee181748dbf827d91a7ebf0c0f1d7878a0
Parent:        1200b7e7c2be18fcd2644817a5e57c6182800ee0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 15:54:51 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:26 2013 +0100

thin: merge display

---
 lib/display/display.c |    6 ++++++
 lib/metadata/lv.c     |    3 ++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 2fd37a2..1babffc 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -607,8 +607,14 @@ int lvdisplay_full(struct cmd_context *cmd,
 		if (seg->external_lv)
 			log_print("LV External origin name %s",
 				  seg->external_lv->name);
+		if (seg->merge_lv)
+			log_print("LV merging to          %s",
+				  seg->merge_lv->name);
 		if (inkernel)
 			thin_active = lv_thin_percent(lv, 0, &thin_percent);
+		if (lv_is_merging_origin(lv))
+			log_print("LV merged with         %s",
+				  find_snapshot(lv)->lv->name);
 	} else if (lv_is_thin_pool(lv)) {
 		if (inkernel) {
 			thin_data_active = lv_thin_pool_percent(lv, 0, &thin_data_percent);
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index c1f6271..3e1458c 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -555,7 +555,8 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else if (lv->status & MIRRORED)
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'M' : 'm';
 	else if (lv_is_thin_volume(lv))
-		repstr[0] = 'V';
+		repstr[0] = lv_is_merging_origin(lv) ?
+			'O' : (lv_is_merging_thin_snapshot(lv) ? 'S' : 'V');
 	else if (lv->status & VIRTUAL)
 		repstr[0] = 'v';
 	else if (lv_is_thin_pool(lv))


