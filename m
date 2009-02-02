From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:50:00 -0500
Subject: [PATCH 04/13] Add lvm_pv_name, lvm_vg_name, and lvm_lv_name accessors.
In-Reply-To: <1233607809-1087-4-git-send-email-dwysocha@redhat.com>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1233607809-1087-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RFC - liblvm could provide accessor functions such as these along with
the generic attribute functions.  These specific accessor functions will
make application code simpler and more readable and may be desired by
application programmers over the generic attribute functions for single
attributes.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h              |    7 +++++++
 lib/metadata/metadata.c |   15 +++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index bfa1852..5f44614 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -69,4 +69,11 @@ typedef struct physical_volume pv_t;
 struct logical_volume;
 typedef struct logical_volume lv_t;
 
+/*
+ * PV, VG, and LV object attribute functions.
+ */
+const char *lvm_pv_name(const pv_t *pv);
+const char *lvm_vg_name(const vg_t *vg);
+const char *lvm_lv_name(const lv_t *lv);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a2b5f2f..4c9f939 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2673,6 +2673,21 @@ vg_t *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
 	return vg_read(cmd, vg_name, vgid, flags | READ_FOR_UPDATE);
 }
 
+const char *lvm_pv_name(const pv_t *pv)
+{
+	return dev_name(pv->dev);
+}
+
+const char *lvm_vg_name(const vg_t *vg)
+{
+	return vg->name;
+}
+
+const char *lvm_lv_name(const lv_t *lv)
+{
+	return lv->name;
+}
+
 /*
  * Test the validity of a VG handle returned by vg_read() or vg_read_for_update().
  *
-- 
1.5.5.1


