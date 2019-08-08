From: David Teigland <teigland@sourceware.org>
Date: Thu, 8 Aug 2019 16:45:42 -0400
Subject: master - tests: open-file-limit
Message-ID: <201908082045.x78Kjg9b013846@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3fcb4697f652e8f439b865f3b544b83576c156ae
Commit:        3fcb4697f652e8f439b865f3b544b83576c156ae
Parent:        ecefcc9ca89982dbc5cc6b210da7ca9d0fef655b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 8 15:21:26 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 8 15:45:03 2019 -0500

tests: open-file-limit

---
 test/shell/open-file-limit.sh |   46 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/test/shell/open-file-limit.sh b/test/shell/open-file-limit.sh
new file mode 100644
index 0000000..87b0f7e
--- /dev/null
+++ b/test/shell/open-file-limit.sh
@@ -0,0 +1,46 @@
+#!/bin/bash
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test scan_lvs config setting
+
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_LVMLOCKD=1
+
+. lib/inittest
+
+aux lvmconf 'devices/pv_min_size = 1024'
+
+aux prepare_devs 200 1
+
+for i in $(seq 1 200); do
+	pvcreate "$DM_DEV_DIR/mapper/${PREFIX}pv$i"
+done
+
+pvs > out
+test "$(grep pv out | wc -l)" -eq 200
+
+# Set the soft limit to 100 fd's when 200 PVs need to be open.
+# This requires lvm to increase its soft limit in order to
+# process all the PVs.
+# Test this with and without udev providing device lists.
+
+aux lvmconf 'devices/obtain_device_list_from_udev = 0'
+
+prlimit --nofile=100: pvs > out
+
+test "$(grep pv out | wc -l)" -eq 200
+
+aux lvmconf 'devices/obtain_device_list_from_udev = 1'
+
+prlimit --nofile=100: pvs > out
+
+test "$(grep pv out | wc -l)" -eq 200
+


