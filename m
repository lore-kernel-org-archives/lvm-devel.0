From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 16 Feb 2009 21:55:17 -0500
Subject: [PATCH 3/3] Add duplicate vg test.
In-Reply-To: <1234839317-20159-3-git-send-email-dwysocha@redhat.com>
References: <20090216190806.GA26197@agk.fab.redhat.com>
	<1234839317-20159-1-git-send-email-dwysocha@redhat.com>
	<1234839317-20159-2-git-send-email-dwysocha@redhat.com>
	<1234839317-20159-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1234839317-20159-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This test demonstrates a bug in vg_read() when duplicate vgs are in the system
(duplicate vgnames but differing vgids).  To demonstrate, you should have 2
such vgs visible in the system.  Then compile and run as follows.

Compile (from test/api directory):
gcc ./duplicate-vg-test.c -I../../include -I../../libdm -L../../lib -L../../libdm -llvm -ldevmapper

Run:
./a.out vg1 Y6mFZP5CcjZcpzkjZKqgbBnRAbyGYbH1 vg1 pWSu1RugZH0fIpUzlZimuOIreBC7joCe

You should see output such as the following which demonstrates the bug (note actual/expected uuid
on VG2 indicating the wrong VG has been opened):
  WARNING: Duplicate VG name vg1: Existing pWSu1R-ugZH-0fIp-UzlZ-imuO-IreB-C7joCe (created here) takes precedence over Y6mFZP-5Ccj-Zcpz-kjZK-qgbB-nRAb-yGYbH1
VG1 - name: vg1/vg1 (actual/expected) UUID: Y6mFZP5CcjZcpzkjZKqgbBnRAbyGYbH1/Y6mFZP5CcjZcpzkjZKqgbBnRAbyGYbH1 (actual/expected)
VG2 - name: vg1/vg1 (actual/expected) UUID: Y6mFZP5CcjZcpzkjZKqgbBnRAbyGYbH1/pWSu1RugZH0fIpUzlZimuOIreBC7joCe (actual/expected)

Applying the "Update lvmcache_update_vg to use vgid as well as vgname" patch
will produce the expected output:
  WARNING: Duplicate VG name vg1: Existing pWSu1R-ugZH-0fIp-UzlZ-imuO-IreB-C7joCe (created here) takes precedence over Y6mFZP-5Ccj-Zcpz-kjZK-qgbB-nRAb-yGYbH1
VG1 - name: vg1/vg1 (actual/expected) UUID: Y6mFZP5CcjZcpzkjZKqgbBnRAbyGYbH1/Y6mFZP5CcjZcpzkjZKqgbBnRAbyGYbH1 (actual/expected)
VG2 - name: vg1/vg1 (actual/expected) UUID: pWSu1RugZH0fIpUzlZimuOIreBC7joCe/pWSu1RugZH0fIpUzlZimuOIreBC7joCe (actual/expected)

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/duplicate-vg-test.c |   69 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 69 insertions(+), 0 deletions(-)
 create mode 100644 test/api/duplicate-vg-test.c

diff --git a/test/api/duplicate-vg-test.c b/test/api/duplicate-vg-test.c
new file mode 100644
index 0000000..7466f68
--- /dev/null
+++ b/test/api/duplicate-vg-test.c
@@ -0,0 +1,69 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
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
+#include <string.h>
+#include <stdlib.h>
+#include "libdevmapper.h"
+#include "lvm-types.h"
+#include "metadata.h"
+#include "metadata-exported.h"
+#include "lvm2.h"
+#include "locking.h"
+
+void _test_duplicate_vgs(void *h, int argc, char *argv[])
+{
+	vg_t *vg1, *vg2;
+
+	if (argc <= 4) {
+		printf("Enter vg1name, vg1uuid, vg2name, vg2uuid\n");
+		return;
+	}
+	if (!(vg1 = vg_read(h, argv[1], argv[2], 0))) {
+		printf("Error opening vg1, name=%s, uuid=%s\n",
+			argv[1], argv[2]);
+		return;
+	}
+	if (!(vg2 = vg_read(h, argv[3], argv[4], 0))) {
+		printf("Error opening vg1, name=%s, uuid=%s\n",
+			argv[3], argv[4]);
+		return;
+	}
+	
+	printf("VG1 - name: %s/%s (actual/expected) UUID: %s/%s (actual/expected)\n",
+		lvm_vg_name(vg1), argv[1], lvm_vg_uuid(vg1), argv[2]);
+	printf("VG2 - name: %s/%s (actual/expected) UUID: %s/%s (actual/expected)\n",
+		lvm_vg_name(vg2), argv[3], lvm_vg_uuid(vg2), argv[4]);
+	unlock_vg(h, lvm_vg_name(vg1));
+	unlock_vg(h, lvm_vg_name(vg2));
+}
+
+int main (int argc, char *argv[])
+{
+	void *h;
+
+	h = lvm2_create();
+	if (!h) {
+		printf("Unable to open lvm library instance\n");
+		return 1;
+	}
+	init_locking(1, h);
+
+	_test_duplicate_vgs(h, argc, argv);
+
+	if (h)
+		lvm2_destroy(h);
+	return 0;
+}
+
-- 
1.6.0.6


