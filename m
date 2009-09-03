From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  3 Sep 2009 13:15:09 -0400
Subject: [PATCH] Add lvm2app.sh to nightly testsuite.
Message-ID: <1251998109-6867-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

More tests to come but for now just call into vgtest.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/Makefile.in  |    2 +-
 test/t-lvm2app.sh |   23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+), 1 deletions(-)
 create mode 100755 test/t-lvm2app.sh

diff --git a/test/Makefile.in b/test/Makefile.in
index aa4bab4..6fb09d9 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -40,7 +40,7 @@ init.sh: Makefile.in .bin-dir-stamp bin/not bin/harness
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
 	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
 	echo 'PATH=$(abs_top_builddir)/test/bin:$$PATH' >> $@-t
-	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/dmeventd"' >> $@-t
+	echo 'export LD_LIBRARY_PATH="$(abs_top_builddir)/libdm:$(abs_top_builddir)/liblvm:$(abs_top_builddir)/dmeventd"' >> $@-t
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t
diff --git a/test/t-lvm2app.sh b/test/t-lvm2app.sh
new file mode 100755
index 0000000..1a9372b
--- /dev/null
+++ b/test/t-lvm2app.sh
@@ -0,0 +1,23 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# tests lvm2app library
+#
+
+. ./test-utils.sh
+
+aux prepare_devs 2
+
+pvcreate $dev1 $dev2
+
+echo `pwd`
+ls -lR `pwd`
+../api/vgtest $vg1 $dev1 $dev2
-- 
1.6.0.6


