From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 11 Sep 2020 19:53:46 +0000 (GMT)
Subject: master - pvmove: check return value of top_level_lv_name()
Message-ID: <20200911195346.30358386F027@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d71199920fe3a43582c0f2ca629ad502cfb189b5
Commit:        d71199920fe3a43582c0f2ca629ad502cfb189b5
Parent:        c38c4d9d36d765bbbe839c00b9580f6b1b8a0ef4
Author:        Wu Guanghao <wuguanghao3@huawei.com>
AuthorDate:    Fri Sep 11 17:40:09 2020 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:43:08 2020 +0200

pvmove: check return value of top_level_lv_name()

The return value of top_level_lv_name() may be NULL, so we should
check return value of top_level_lv_name before calling
strcmp(lv->name, top_level_lv_name(vg, lv_name)).

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
Signed-off-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 tools/pvmove.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index cc512b9de..da635a662 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -326,6 +326,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	int lv_skipped = 0;
 	int needs_exclusive = *exclusive;
 	const struct logical_volume *holder;
+	const char *new_lv_name;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -363,8 +364,13 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (lv == lv_mirr)
 			continue;
 
-		if (lv_name && strcmp(lv->name, top_level_lv_name(vg, lv_name)))
-			continue;
+		if (lv_name) {
+			if (!(new_lv_name = top_level_lv_name(vg, lv_name)))
+				return_NULL;
+
+			if (strcmp(lv->name, new_lv_name))
+				continue;
+		}
 
 		if (!lv_is_on_pvs(lv, source_pvl))
 			continue;


