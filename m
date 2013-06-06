From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  6 Jun 2013 10:17:05 +0000 (UTC)
Subject: master - tests: performance testing
Message-ID: <20130606101705.DE7C160EB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b24aad1622a540ab71bc9e9425bdecfc17f443c9
Commit:        b24aad1622a540ab71bc9e9425bdecfc17f443c9
Parent:        215ab4c9cec497465a60b91ef53046665ed5e1d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 6 12:14:53 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 6 12:14:53 2013 +0200

tests: performance testing

Tests speed of activation and deactivation of a lot of volumes.
Currently limited to 1000LVs
TODO: explore why lvmetad fails with higher number.
---
 test/shell/vgchange-many.sh |   52 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
new file mode 100644
index 0000000..491c8b1
--- /dev/null
+++ b/test/shell/vgchange-many.sh
@@ -0,0 +1,52 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Check perfomance of activation and deactivation
+. lib/test
+
+# FIXME: lvmetad fails with i.e. 1500 device on memory failure...
+
+# Number of LVs to create
+DEVICES=1000
+
+aux prepare_pvs 1 400
+
+vgcreate -s 128K $vg $(cat DEVICES)
+
+vgcfgbackup -f data $vg
+
+# Generate a lot of devices (size of 1 extent)
+awk -v DEVICES=$DEVICES '/^\t\}/ { \
+    printf("\t}\n\tlogical_volumes {\n");\
+    cnt=0;
+    for (i = 0; i < DEVICES; i++) { \
+	printf("\t\tlvol%06d  {\n", i);\
+	printf("\t\t\tid = \"%06d-1111-2222-3333-2222-1111-%06d\"\n", i, i); \
+	print "\t\t\tstatus = [\"READ\", \"WRITE\", \"VISIBLE\"]"; \
+	print "\t\t\tsegment_count = 1"; \
+	print "\t\t\tsegment1 {"; \
+	print "\t\t\t\tstart_extent = 0"; \
+	print "\t\t\t\textent_count = 1"; \
+	print "\t\t\t\ttype = \"striped\""; \
+	print "\t\t\t\tstripe_count = 1"; \
+	print "\t\t\t\tstripes = ["; \
+	print "\t\t\t\t\t\"pv0\", " cnt++; \
+	printf("\t\t\t\t]\n\t\t\t}\n\t\t}\n"); \
+      } \
+  }
+  {print}
+' data >data_new
+
+vgcfgrestore -f data_new $vg
+
+# Activate and deactivate all of them
+vgchange -ay $vg
+vgchange -an $vg


