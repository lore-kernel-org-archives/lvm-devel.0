From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Fri, 11 Sep 2020 17:40:09 +0800
Subject: [PATCH 1/4] pvmove: check return value of top_level_lv_name() in _set_up_pvmove_lv
In-Reply-To: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
References: <2c9f8715-4b9e-d39c-34db-358912c62167@huawei.com>
Message-ID: <1f1b3b6e-1c96-46a9-3c6d-ddeab93f6611@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The return value of top_level_lv_name may be NULL, so we should
check return value of top_level_lv_name before calling
strcmp(lv->name, top_level_lv_name(vg, lv_name)).

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
Signed-off-by: Zhiqiang Liu <liuzhiqiang26@huawei.com>
---
 tools/pvmove.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index cc512b9de..3101de1df 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -326,6 +326,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	int lv_skipped = 0;
 	int needs_exclusive = *exclusive;
 	const struct logical_volume *holder;
+	const char *new_lv_name;

 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -363,7 +364,11 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if (lv == lv_mirr)
 			continue;

-		if (lv_name && strcmp(lv->name, top_level_lv_name(vg, lv_name)))
+		new_lv_name = top_level_lv_name(vg, lv_name);
+		if (!new_lv_name)
+			return NULL;
+
+		if (lv_name && strcmp(lv->name, new_lv_name))
 			continue;

 		if (!lv_is_on_pvs(lv, source_pvl))
-- 


