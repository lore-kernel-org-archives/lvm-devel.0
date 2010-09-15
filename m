From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:27:41 -0400
Subject: [PATCH] Add lvm2app example to docs directory.
Message-ID: <1284564461-25995-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a simple example of using lvm2app to enumerate the system's
VGs, LVs, and PVs.
Build as follows (I tried on f13):
$ gcc example_lvm2app.c -llvm2app -ldevmapper

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 doc/example_lvm2app.c |   87 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 87 insertions(+), 0 deletions(-)
 create mode 100644 doc/example_lvm2app.c

diff --git a/doc/example_lvm2app.c b/doc/example_lvm2app.c
new file mode 100644
index 0000000..5feba33
--- /dev/null
+++ b/doc/example_lvm2app.c
@@ -0,0 +1,87 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lvm2app.h"
+#include <stdio.h>
+
+static void _process_vg(lvm_t lvm, vg_t vg)
+{
+	struct dm_list *lvs, *pvs;
+	struct lvm_pv_list *pvl;
+	struct lvm_lv_list *lvl;
+
+	if (!vg) {
+		fprintf(stderr, "Error opening volume group");
+		return;
+	}
+	printf("vg_name: %s, vg_uuid: %s\n", lvm_vg_get_name(vg),
+	       lvm_vg_get_uuid(vg));
+	pvs = lvm_vg_list_pvs(vg);
+	if (!pvs && lvm_errno(lvm)) {
+		fprintf(stderr, "lvm_vg_list_pvs() failed\n");
+		return;
+	} else if (!pvs) {
+		fprintf(stdout, "- No PVs, error!\n");
+		return;
+	}
+	dm_list_iterate_items(pvl, pvs) {
+		printf("- pv_name: %s, pv_uuid: %s\n",
+			lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv));
+	}
+	lvs = lvm_vg_list_lvs(vg);
+	if (!lvs && lvm_errno(lvm)) {
+		fprintf(stderr, "lvm_vg_list_lvs() failed\n");
+		return;
+	} else if (!lvs) {
+		fprintf(stdout, "- No LVs\n");
+		return;
+	}
+	dm_list_iterate_items(lvl, lvs) {
+		printf("- lv_name: %s, lv_uuid: %s\n",
+			lvm_lv_get_name(lvl->lv), lvm_lv_get_uuid(lvl->lv));
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	lvm_t lvm;
+	vg_t vg;
+	struct dm_list *vgnames;
+	struct lvm_str_list *strl;
+
+	lvm = lvm_init(NULL);
+	if (!lvm) {
+		fprintf(stderr, "lvm_init() failed\n");
+		goto bad;
+	}
+
+	printf("Library version: %s\n", lvm_library_get_version());
+	vgnames = lvm_list_vg_names(lvm);
+	if (!vgnames) {
+		fprintf(stderr, "lvm_list_vg_names() failed\n");
+		goto bad;
+	}
+	dm_list_iterate_items(strl, vgnames) {
+		printf("Opening volume group %s\n", strl->str);
+		vg = lvm_vg_open(lvm, strl->str, "r", 0);
+		_process_vg(lvm, vg);
+		lvm_vg_close(vg);
+	}
+	lvm_quit(lvm);
+	exit(0);
+bad:
+	if (lvm)
+		lvm_quit(lvm);
+	exit(-1);
+}
-- 
1.7.2.1


