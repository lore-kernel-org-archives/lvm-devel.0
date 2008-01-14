From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 14 Jan 2008 22:53:45 +0000
Subject: [PATCH 2/11] Add upward link from underlying LV to stacked seg
In-Reply-To: <4787FF72.9000400@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com> <4787FF72.9000400@ce.jp.nec.com>
Message-ID: <20080114225345.GG8075@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 /*
+ * Add/remove upward link from underlying LV to the segment using it
+ */
+int lv_add_user_seg(struct logical_volume *lv, struct lv_segment *seg);
+int lv_remove_user_seg(struct logical_volume *lv, struct lv_segment *seg);

need to rename - too ambiguous

+/*
+ * This is a function specialized for the common case where there is
+ * only one segment which uses the LV.
+ * e.g. the LV is a layer inserted by insert_layer_for_lv().
+ *
+ * In general, walk through lv->segs_using_this_lv.
+ */
+struct lv_segment *seg_using_lv(struct logical_volume *lv)
+{
+	struct seg_list *sl;
+
+	if (list_size(&lv->segs_using_this_lv) != 1)
+		return NULL;

Is it ever valid to return here and not have an error?

+		if (!lv_add_user_seg(log_lv, seg))

Needs a clearer name.

@@ -110,8 +110,8 @@ int check_lv_segments(struct logical_vol
 		}
 
Where is this new list validated?

Alasdair
-- 
agk at redhat.com


