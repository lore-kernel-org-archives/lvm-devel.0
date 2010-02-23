From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 23 Feb 2010 14:30:25 -0500
Subject: [PATCH 3/4] Add an example to the lvm2app.h code, which is also part of the unit testing.
In-Reply-To: <1266953426-20955-3-git-send-email-dwysocha@redhat.com>
References: <1266427744-30327-9-git-send-email-dwysocha@redhat.com>
	<1266953426-20955-1-git-send-email-dwysocha@redhat.com>
	<1266953426-20955-2-git-send-email-dwysocha@redhat.com>
	<1266953426-20955-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1266953426-20955-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h        |    4 +-
 test/api/lvm_list_all.c |  101 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 104 insertions(+), 1 deletions(-)
 create mode 100644 test/api/lvm_list_all.c

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 61ffd87..2301a9e 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -62,7 +62,9 @@
  * whether the original "vg_seqno" obtained with READ permission matches
  * the new one obtained with WRITE permission.
  */
-
+/**
+ * \example lvm_list_all.c
+ */
 /**
  * Retrieve the library version.
  *
diff --git a/test/api/lvm_list_all.c b/test/api/lvm_list_all.c
new file mode 100644
index 0000000..11feac6
--- /dev/null
+++ b/test/api/lvm_list_all.c
@@ -0,0 +1,101 @@
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
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <inttypes.h>
+
+#include "lvm2app.h"
+
+static void _process_vg(vg_t vg);
+/*
+ * List all volume groups, physical volumes, and logical volumes in
+ * the system.  Sample output:
+ *
+ * Opening volume group VolGroup00
+ * vg_name: VolGroup00, vg_uuid: OQ2d4T-qzZ7-k73u-vHt8-9T33-kTk8-ZjW4qZ
+ * - lv_name: LogVol00, lv_uuid: bFO4EU-UaDu-iuMm-N6BA-xcZc-nm3u-J5K5lu
+ * - lv_name: LogVol01, lv_uuid: BHGsPK-PwzY-kye0-MEWa-a67z-BiYE-03ZjwM
+ * - pv_name: /dev/sda2, pv_uuid: Be91pt-CqT0-4YJE-nGI6-Oisz-hy0N-l9CHgn
+ * Opening volume group vgtest
+ * vg_name: vgtest, vg_uuid: Bo3niX-gRkd-FMf2-wIdR-Hgao-MZdM-diQrxh
+ * - lv_name: lv0, lv_uuid: x5nTlk-UvuT-GJHE-mPiL-Nc6u-O2nW-AkXpfo
+ * - lv_name: lv1, lv_uuid: fZ6KbM-f3YT-vsR6-XPoc-XDcY-evv5-RhzlCQ
+ * - pv_name: /dev/loop0, pv_uuid: xe6FGu-ya5h-677k-mVlc-bpok-dawg-8tIfOh
+ * - pv_name: /dev/loop1, pv_uuid: 1voe8u-fBCz-lliH-kDFR-vNx7-sZoy-RZP7ts
+ * - pv_name: /dev/loop2, pv_uuid: dGJvCt-fSrY-1azp-r9rG-Kxby-Shon-RWbhZI
+ */
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
+		_process_vg(vg);
+		lvm_vg_close(vg);
+	}
+	lvm_quit(lvm);
+	_exit(0);
+bad:
+	if (lvm)
+		lvm_quit(lvm);
+	_exit(-1);
+}
+
+static void _process_vg(vg_t vg)
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
+	lvs = lvm_vg_list_lvs(vg);
+	if (!lvs) {
+		fprintf(stderr, "lvm_vg_list_lvs() failed\n");
+		return;
+	}
+	dm_list_iterate_items(lvl, lvs) {
+		printf("- lv_name: %s, lv_uuid: %s\n",
+			lvm_lv_get_name(lvl->lv), lvm_lv_get_uuid(lvl->lv));
+	}
+	pvs = lvm_vg_list_pvs(vg);
+	if (!pvs) {
+		fprintf(stderr, "lvm_vg_list_pvs() failed\n");
+		return;
+	}
+	dm_list_iterate_items(pvl, pvs) {
+		printf("- pv_name: %s, pv_uuid: %s\n",
+			lvm_pv_get_name(pvl->pv), lvm_pv_get_uuid(pvl->pv));
+	}
+}
-- 
1.6.0.6


