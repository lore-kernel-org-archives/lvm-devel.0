From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:38 +0000 (UTC)
Subject: master - tests: add report-fields.sh test
Message-ID: <20151030145238.B22EB609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b04eda93f903d25e25385d148d28b8cfa1157ea
Commit:        5b04eda93f903d25e25385d148d28b8cfa1157ea
Parent:        77c31d0c39c3ba9caf7a5a70282f1c5a6b0f48e2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 30 15:06:49 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

tests: add report-fields.sh test

---
 test/shell/report-fields.sh |   91 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/test/shell/report-fields.sh b/test/shell/report-fields.sh
new file mode 100644
index 0000000..e0c7308
--- /dev/null
+++ b/test/shell/report-fields.sh
@@ -0,0 +1,91 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+SKIP_WITH_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_CLVMD=1
+
+. lib/inittest
+
+# Test only that there's correct set of fields displayed on output.
+
+aux prepare_pvs 1
+
+OPTS="--nameprefixes --noheadings --rows"
+
+aux lvmconf 'report/pvs_cols="pv_name,pv_size"'
+aux lvmconf 'report/compact_output=0'
+aux lvmconf 'report/compact_output_cols=""'
+
+pvs $OPTS > out
+grep LVM2_PV_NAME out
+grep LVM2_PV_SIZE out
+
+pvs $OPTS -o pv_attr > out
+grep LVM2_PV_ATTR out
+not grep -v LVM2_PV_ATTR out
+
+pvs $OPTS -o+pv_attr > out
+grep LVM2_PV_NAME out
+grep LVM2_PV_SIZE out
+grep LVM2_PV_ATTR out
+
+pvs $OPTS -o-pv_name > out
+not grep LVM2_PV_NAME out
+grep LVM2_PV_SIZE out
+
+pvs $OPTS -o+pv_attr -o-pv_attr > out
+grep LVM2_PV_NAME out
+grep LVM2_PV_SIZE out
+not grep LVM2_PV_ATTR out
+
+pvs $OPTS -o-pv_attr -o+pv_attr > out
+grep LVM2_PV_NAME out
+grep LVM2_PV_SIZE out
+grep LVM2_PV_ATTR out
+
+pvs $OPTS -o+pv_attr -o-pv_attr -o pv_attr > out
+grep LVM2_PV_ATTR out
+not grep -v LVM2_PV_ATTR out
+
+# -o-size is the same as -o-pv_size - the prefix is recognized
+pvs $OPTS -o-size > out
+not grep LVM2_PV_SIZE out
+
+# PV does not have tags nor is it exported if we haven't done that explicitly.
+# Check compaction per field is done correctly.
+pvs $OPTS -o pv_name,pv_exported,pv_tags -o#pv_tags > out
+grep LVM2_PV_NAME out
+grep LVM2_PV_EXPORTED out
+not grep LVM2_PV_TAGS out
+
+aux lvmconf 'report/compact_output_cols="pv_tags"'
+
+pvs $OPTS -o pv_name,pv_exported,pv_tags > out
+grep LVM2_PV_NAME out
+grep LVM2_PV_EXPORTED out
+not grep LVM2_PV_TAGS out
+
+pvs $OPTS -o pv_name,pv_exported,pv_tags -o#pv_exported > out
+grep LVM2_PV_NAME out
+not grep LVM2_PV_EXPORTED out
+grep LVM2_PV_TAGS out
+
+aux lvmconf 'report/compact_output=1'
+pvs $OPTS -o pv_name,pv_exported,pv_tags > out
+grep LVM2_PV_NAME out
+not grep LVM2_PV_EXPORTED out
+not grep LVM2_PV_TAGS out
+
+pvs $OPTS -o pv_name,pv_exported,pv_tags -o#pv_exported > out
+grep LVM2_PV_NAME out
+not grep LVM2_PV_EXPORTED out
+not grep LVM2_PV_TAGS out


