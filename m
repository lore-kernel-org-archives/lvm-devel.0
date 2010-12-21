From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:50 +0100
Subject: [PATCH 18/23] Return PERCENT_INVALID for error case
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <988f227f76fc6371eeed50b7120887c701a582d2.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If the percent value could not be determined - return PERCENT_INVALD.
Indent function with tabs.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/report/properties.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 0b4929a..06e11ba 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -87,15 +87,18 @@ static int _not_implemented_set(void *obj, struct lvm_property_type *prop)
 }
 
 static percent_t _copy_percent(const struct logical_volume *lv) {
-    percent_t perc;
-    lv_mirror_percent(lv->vg->cmd, (struct logical_volume *) lv, 0, &perc, NULL);
-    return perc;
+	percent_t perc;
+	if (!lv_mirror_percent(lv->vg->cmd, (struct logical_volume *) lv,
+			   0, &perc, NULL))
+		perc = PERCENT_INVALID;
+	return perc;
 }
 
 static percent_t _snap_percent(const struct logical_volume *lv) {
-    percent_t perc;
-    lv_snapshot_percent(lv, &perc);
-    return perc;
+	percent_t perc;
+	if (!lv_snapshot_percent(lv, &perc))
+		perc = PERCENT_INVALID;
+	return perc;
 }
 
 /* PV */
-- 
1.7.3.4


