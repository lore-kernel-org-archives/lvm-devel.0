From: David Teigland <teigland@sourceware.org>
Date: Thu, 17 May 2018 16:57:34 -0400
Subject: master - liblvm2app: add a couple tests
Message-ID: <201805172057.w4HKvY8K020382@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7435cd8c7bf4c245c9efabbae1274989d2e49ed
Commit:        f7435cd8c7bf4c245c9efabbae1274989d2e49ed
Parent:        286c9c78b49f3b52bb05cef93659bb91e4249dc9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 17 15:55:44 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 17 15:55:44 2018 -0500

liblvm2app: add a couple tests

trivial sanity-check programs using liblvm2app
---
 liblvm/test/vgadd.c  |   90 +++++++++++++++++++++++++++++++++++++++++++++++
 liblvm/test/vgshow.c |   95 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 185 insertions(+), 0 deletions(-)

diff --git a/liblvm/test/vgadd.c b/liblvm/test/vgadd.c
new file mode 100644
index 0000000..c96baa7
--- /dev/null
+++ b/liblvm/test/vgadd.c
@@ -0,0 +1,90 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include <stdio.h>
+#include <unistd.h>
+#include <inttypes.h>
+#include <assert.h>
+
+#include "lvm2app.h"
+
+int main(int argc, char *argv[])
+{
+	char *vgname = NULL;
+	lvm_t handle;
+	vg_t vg;
+	lv_t lv;
+	lvm_str_list_t *sl;
+	pv_list_t *pvl;
+	lv_list_t *lvl;
+	struct dm_list *vgnames;
+	struct dm_list *vgids;
+	struct dm_list *pvlist;
+	struct dm_list *lvlist;
+	int added = 0;
+	int ret;
+	int i;
+
+	vgname = argv[1];
+
+	handle = lvm_init(NULL);
+	if (!handle) {
+		printf("lvm_init failed\n");
+		return -1;
+	}
+
+	vg = lvm_vg_create(handle, vgname);
+
+	for (i = 2; i < argc; i++) {
+		printf("adding %s to vg\n", argv[i]);
+		ret = lvm_vg_extend(vg, argv[i]);
+
+		if (ret) {
+			printf("Failed to add %s to vg\n", argv[i]);
+			goto out;
+		}
+
+		added++;
+	}
+
+	if (!added) {
+		printf("No PVs added, not writing VG.\n");
+		goto out;
+	}
+
+	printf("writing vg\n");
+	ret = lvm_vg_write(vg);
+
+	lvm_vg_close(vg);
+
+	sleep(1);
+
+	vg = lvm_vg_open(handle, vgname, "w", 0);
+	if (!vg) {
+		printf("vg open %s failed\n", vgname);
+		goto out;
+	}
+
+	lv = lvm_vg_create_lv_linear(vg, "lv0", 1024*1024);
+	if (!lv) {
+		printf("lv create failed\n");
+		goto out;
+	}
+
+	lvm_vg_close(vg);
+out:
+	lvm_quit(handle);
+
+	return 0;
+}
diff --git a/liblvm/test/vgshow.c b/liblvm/test/vgshow.c
new file mode 100644
index 0000000..519f3dd
--- /dev/null
+++ b/liblvm/test/vgshow.c
@@ -0,0 +1,95 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include <stdio.h>
+#include <unistd.h>
+#include <inttypes.h>
+#include <assert.h>
+
+#include "lvm2app.h"
+
+int main(int argc, char *argv[])
+{
+	char *vgname = NULL;
+	lvm_t handle;
+	vg_t vg;
+	lvm_str_list_t *sl;
+	pv_list_t *pvl;
+	lv_list_t *lvl;
+	struct dm_list *vgnames;
+	struct dm_list *vgids;
+	struct dm_list *pvlist;
+	struct dm_list *lvlist;
+	uint64_t val;
+
+	vgname = argv[1];
+
+	handle = lvm_init(NULL);
+	if (!handle) {
+		printf("lvm_init failed\n");
+		return -1;
+	}
+
+	vgnames = lvm_list_vg_names(handle);
+
+	dm_list_iterate_items(sl, vgnames)
+		printf("vg name %s\n", sl->str);
+
+	vgids = lvm_list_vg_uuids(handle);
+
+	dm_list_iterate_items(sl, vgids)
+		printf("vg uuid %s\n", sl->str);
+
+	if (!vgname) {
+		printf("No vg name arg\n");
+		goto out;
+	}
+
+	vg = lvm_vg_open(handle, vgname, "r", 0);
+
+	if (!vg) {
+		printf("vg open %s failed\n", vgname);
+		goto out;
+	}
+
+	val = lvm_vg_get_seqno(vg);
+
+	printf("vg seqno %llu\n", (unsigned long long)val);
+
+	pvlist = lvm_vg_list_pvs(vg);
+	
+	dm_list_iterate_items(pvl, pvlist) {
+		printf("vg pv name %s\n", lvm_pv_get_name(pvl->pv));
+
+		val = lvm_pv_get_dev_size(pvl->pv);
+
+		printf("vg pv size %llu\n", (unsigned long long)val);
+	}
+
+	lvlist = lvm_vg_list_lvs(vg);
+	
+	dm_list_iterate_items(lvl, lvlist) {
+		printf("vg lv name %s\n", lvm_lv_get_name(lvl->lv));
+
+		val = lvm_lv_get_size(lvl->lv);
+
+		printf("vg lv size %llu\n", (unsigned long long)val);
+	}
+
+	lvm_vg_close(vg);
+out:
+	lvm_quit(handle);
+
+	return 0;
+}


