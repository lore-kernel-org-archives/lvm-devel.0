From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  1 Apr 2014 13:53:22 +0000 (UTC)
Subject: master - tests: add profiles-thin and prepare_profiles helper fn
Message-ID: <20140401135322.9230E60FE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=504c328e3d2c0a8b6b946fe7d323e1f28887e285
Commit:        504c328e3d2c0a8b6b946fe7d323e1f28887e285
Parent:        af73a0a5189c7d6abf6798952224dfe1b93d00d1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 1 15:51:46 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 1 15:52:54 2014 +0200

tests: add profiles-thin and prepare_profiles helper fn

---
 test/Makefile.in            |    2 +
 test/lib/aux.sh             |    8 ++++++
 test/shell/profiles-thin.sh |   56 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index fe33949..7253bb4 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -177,6 +177,8 @@ CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
 	ln -fs $(abs_top_builddir)/daemons/lvmetad/lvmetad lib/lvmetad
 	ln -fs $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
 	ln -fs $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
+	ln -fs $(abs_top_srcdir)/conf/default.profile lib/default.profile
+	ln -fs $(abs_top_srcdir)/conf/thin-performance.profile lib/thin-performance.profile
 	touch $@
 
 clean:
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index aa4c7a6..76cfd82 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -632,6 +632,14 @@ profileconf() {
 	mv -f PROFILE_$profile_name etc/profile/$profile_name.profile
 }
 
+prepare_profiles() {
+	test -d etc/profile || mkdir etc/profile
+	for profile_name in $@; do
+		test -L "$abs_top_builddir/test/lib/$profile_name.profile" || skip
+		cp "$abs_top_builddir/test/lib/$profile_name.profile" "etc/profile/$profile_name.profile"
+	done
+}
+
 apitest() {
 	local t=$1
 	shift
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
new file mode 100644
index 0000000..1056528
--- /dev/null
+++ b/test/shell/profiles-thin.sh
@@ -0,0 +1,56 @@
+#!/bin/sh
+
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+#
+# test thin profile functionality
+#
+
+. lib/test
+
+DEV_SIZE=32
+
+aux prepare_profiles "thin-performance"
+
+# Create scsi debug dev with sector size of 4096B and 1MiB optimal_io_size
+aux prepare_scsi_debug_dev $DEV_SIZE sector_size=4096 opt_blks=256
+aux prepare_pvs 1 $DEV_SIZE
+vgcreate $vg "$dev1"
+
+# By default, "generic" policy is used to
+# calculate chunk size which is 64KiB by default
+# or minimum_io_size if it's higher. Also, zeroing is used
+# under default operation.
+lvcreate -L8m -T $vg/pool_generic
+check lv_field $vg/pool_generic profile ""
+check lv_field $vg/pool_generic chunk_size 64.00k
+check lv_field $vg/pool_generic zero 1
+
+# If "thin-performance" profile is used, the "performance"
+# policy is used to calculate chunk size which is 512KiB
+# or optimal_io_suize if it's higher. Our test device has
+# 1MiB, so that should be used. Also, zeroing is not used
+# under "thin-perforance" profile.
+lvcreate --profile thin-performance -L8m -T $vg/pool_performance
+check lv_field $vg/pool_performance profile "thin-performance"
+check lv_field $vg/pool_performance chunk_size 1.00m
+check lv_field $vg/pool_performance zero 0
+
+vgremove -ff $vg
+
+# The profile must be also applied if using the profile
+# for the whole VG - any LVs inherit this profile then.
+vgcreate --profile thin-performance $vg "$dev1"
+lvcreate -L8m -T $vg/pool_performance_inherited
+# ...the LV does not have the profile attached, but VG does!
+check vg_field $vg profile "thin-performance"
+check lv_field $vg/pool_performance_inherited profile ""
+check lv_field $vg/pool_performance_inherited chunk_size 1.00m
+check lv_field $vg/pool_performance_inherited zero 0


