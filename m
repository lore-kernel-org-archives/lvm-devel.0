From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:50:06 -0500
Subject: [PATCH 10/13] Add lvm_pvs_in_vg().
In-Reply-To: <1233607809-1087-10-git-send-email-dwysocha@redhat.com>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-8-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-9-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1233607809-1087-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

NOTE: struct lvm_pv_list should not be necessary but I did not like exposing
struct pv_list and attempts to clean up struct pv_list to contain only
struct dm_list and pv_t members were unsuccessful.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h              |   10 ++++++++++
 lib/metadata/metadata.c |   10 ++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index 4d25d25..25ce12d 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -91,4 +91,14 @@ struct lvm_lv_list {
 };
 struct dm_list *lvm_lvs_in_vg(vg_t *vg);
 
+/*
+ * FIXME: struct lvm_pv_list is not equivalent to struct pv_list, which
+ * is used in lvm_pvs_in_vg().  Ideally we should not need a new structure.
+ */
+struct lvm_pv_list {
+	struct dm_list list;
+	pv_t *pv;
+};
+struct dm_list *lvm_pvs_in_vg(vg_t *vg);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0fa5db4..450e781 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2496,6 +2496,16 @@ void lvm_vg_close(vg_t *vg)
 		unlock_vg(vg->cmd, vg->name);
 }
 
+struct dm_list *lvm_lvs_in_vg(vg_t *vg)
+{
+	return (&vg->lvs);
+}
+
+struct dm_list *lvm_pvs_in_vg(vg_t *vg)
+{
+	return (&vg->pvs);
+}
+
 /*
  * Create a (vg_t) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
-- 
1.5.5.1


