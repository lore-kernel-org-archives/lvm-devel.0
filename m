From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:36 +0000 (GMT)
Subject: stable-2.02 - pvmove: check return value of top_level_lv_name()
Message-ID: <20201016191136.17889396E83D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=844037ecdf64be306310ba48f4ae593cc8fde970
Commit:        844037ecdf64be306310ba48f4ae593cc8fde970
Parent:        5b579fa79655ca7cf61ce0d7723b42f5ac741f2b
Author:        Wu Guanghao <wuguanghao3@huawei.com>
AuthorDate:    Fri Sep 11 17:40:09 2020 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

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
index cecff00e8..d2776d1c9 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -342,6 +342,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	int lv_skipped = 0;
 	int needs_exclusive = *exclusive;
 	const struct logical_volume *holder;
+	const char *new_lv_name;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -379,8 +380,13 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
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


