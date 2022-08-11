From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 11 Aug 2022 11:06:15 +0000 (GMT)
Subject: main - test: add report-format test
Message-ID: <20220811110615.7A1A33858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af2b51d25fb76451d19cb27d22ea0c72f386e33e
Commit:        af2b51d25fb76451d19cb27d22ea0c72f386e33e
Parent:        fc8fda641781d0978ff22ad0a59d5a19b5e450e1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 11 10:57:06 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 11 11:10:11 2022 +0200

test: add report-format test

---
 test/shell/report-format.sh | 74 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 74 insertions(+)

diff --git a/test/shell/report-format.sh b/test/shell/report-format.sh
new file mode 100644
index 000000000..07fa02778
--- /dev/null
+++ b/test/shell/report-format.sh
@@ -0,0 +1,74 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2022 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_vg 1
+
+OUT_LOG_FILE="out"
+
+lvcreate -l1 -T $vg/$lv1
+lvcreate -l1 -n $lv2 --addtag lv_tag1 -an $vg
+lvcreate -l1 -n $lv3 --addtag lv_tag3 --addtag lv_tag1 --addtag lv_tag2 $vg
+
+aux lvmconf "report/output_format = basic"
+lvs -o name,kernel_major,data_percent,tags | tee "$OUT_LOG_FILE"
+
+#
+#  LV    KMaj Data%  LV Tags
+#  lvol1  253 0.00
+#  lvol2   -1        lv_tag1
+#  lvol3  253        lv_tag1,lv_tag2,lv_tag3
+#
+grep -E "^[[:space:]]*$lv1[[:space:]]*[[:digit:]]+[[:space:]]*[[:digit:]]+.[[:digit:]]+[[:space:]]*\$" out
+grep -E "^[[:space:]]*$lv2[[:space:]]*-1[[:space:]]*lv_tag1[[:space:]]*\$" out
+grep -E "^[[:space:]]*$lv3[[:space:]]*[[:digit:]]+[[:space:]]*lv_tag1,lv_tag2,lv_tag3\$" out
+
+
+aux lvmconf "report/output_format = json"
+lvs -o name,kernel_major,data_percent,tags | tee "$OUT_LOG_FILE"
+#  {
+#      "report": [
+#          {
+#              "lv": [
+#                  {"lv_name":"lvol1", "lv_kernel_major":"253", "data_percent":"0.00", "lv_tags":""},
+#                  {"lv_name":"lvol2", "lv_kernel_major":"-1", "data_percent":"", "lv_tags":"lv_tag1"},
+#                  {"lv_name":"lvol3", "lv_kernel_major":"253", "data_percent":"", "lv_tags":"lv_tag1,lv_tag2,lv_tag3"}
+#              ]
+#          }
+#      ]
+#  }
+grep -E "^[[:space:]]*{\"lv_name\":\"$lv1\", \"lv_kernel_major\":\"[[:digit:]]+\", \"data_percent\":\"[[:digit:]]+.[[:digit:]]+\", \"lv_tags\":\"\"},\$" out
+grep -E "^[[:space:]]*{\"lv_name\":\"$lv2\", \"lv_kernel_major\":\"-1\", \"data_percent\":\"\", \"lv_tags\":\"lv_tag1\"},\$" out
+grep -E "^[[:space:]]*{\"lv_name\":\"$lv3\", \"lv_kernel_major\":\"[[:digit:]]+\", \"data_percent\":\"\", \"lv_tags\":\"lv_tag1,lv_tag2,lv_tag3\"}\$" out
+
+aux lvmconf "report/output_format = json_std"
+lvs -o name,kernel_major,data_percent,tags | tee "$OUT_LOG_FILE"
+#  {
+#      "report": [
+#          {
+#              "lv": [
+#                  {"lv_name":"lvol1", "lv_kernel_major":253, "data_percent":0.00, "lv_tags":[]},
+#                  {"lv_name":"lvol2", "lv_kernel_major":-1, "data_percent":null, "lv_tags":["lv_tag1"]},
+#                  {"lv_name":"lvol3", "lv_kernel_major":253, "data_percent":null, "lv_tags":["lv_tag1","lv_tag2","lv_tag3"]}
+#              ]
+#          }
+#      ]
+#  }
+grep -E "^[[:space:]]*{\"lv_name\":\"$lv1\", \"lv_kernel_major\":[[:digit:]]+, \"data_percent\":[[:digit:]]+.[[:digit:]]+, \"lv_tags\":\[\]},\$" out
+grep -E "^[[:space:]]*{\"lv_name\":\"$lv2\", \"lv_kernel_major\":-1, \"data_percent\":null, \"lv_tags\":\[\"lv_tag1\"\]},\$" out
+grep -E "^[[:space:]]*{\"lv_name\":\"$lv3\", \"lv_kernel_major\":[[:digit:]]+, \"data_percent\":null, \"lv_tags\":\[\"lv_tag1\",\"lv_tag2\",\"lv_tag3\"\]}\$" out
+
+vgremove -ff $vg

