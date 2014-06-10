From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Jun 2014 08:52:07 +0000 (UTC)
Subject: master - tests: rename test to inittest
Message-ID: <20140610085207.BECF160A38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c5177c37c88cc0e7d5fbd5b82647ce562dad32f
Commit:        5c5177c37c88cc0e7d5fbd5b82647ce562dad32f
Parent:        9f68aadb742b9cbd70c5cf5d750b64ff534bc8b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 6 17:40:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 10 10:51:27 2014 +0200

tests: rename test to inittest

We are getting into problem when we use 'test' for commands like
should/not/...

So avoid overloading test name and change it to inittest.
---
 test/Makefile.in                                  |    2 +-
 test/lib/inittest.sh                              |  102 +++++++++++++++++++++
 test/lib/test.sh                                  |  102 ---------------------
 test/shell/000-basic.sh                           |    2 +-
 test/shell/activate-minor.sh                      |    2 +-
 test/shell/activate-missing-segment.sh            |    2 +-
 test/shell/activate-missing.sh                    |    2 +-
 test/shell/activate-partial.sh                    |    2 +-
 test/shell/activation-skip.sh                     |    2 +-
 test/shell/clvmd-restart.sh                       |    2 +-
 test/shell/covercmd.sh                            |    2 +-
 test/shell/discards-thin.sh                       |    2 +-
 test/shell/dmeventd-restart.sh                    |    2 +-
 test/shell/dumpconfig.sh                          |    2 +-
 test/shell/error-usage.sh                         |    2 +-
 test/shell/fsadm.sh                               |    2 +-
 test/shell/inconsistent-metadata.sh               |    2 +-
 test/shell/listings.sh                            |    2 +-
 test/shell/lock-blocking.sh                       |    2 +-
 test/shell/lock-parallel.sh                       |    2 +-
 test/shell/lvchange-mirror.sh                     |    2 +-
 test/shell/lvchange-partial-raid10.sh             |    2 +-
 test/shell/lvchange-partial.sh                    |    2 +-
 test/shell/lvchange-raid.sh                       |    2 +-
 test/shell/lvchange-syncaction-raid.sh            |    2 +-
 test/shell/lvchange-thin.sh                       |    2 +-
 test/shell/lvconvert-mirror-basic.sh              |    2 +-
 test/shell/lvconvert-mirror-updown.sh             |    2 +-
 test/shell/lvconvert-mirror.sh                    |    2 +-
 test/shell/lvconvert-raid.sh                      |    2 +-
 test/shell/lvconvert-raid10.sh                    |    2 +-
 test/shell/lvconvert-raid456.sh                   |    2 +-
 test/shell/lvconvert-repair-dmeventd.sh           |    2 +-
 test/shell/lvconvert-repair-policy.sh             |    2 +-
 test/shell/lvconvert-repair-raid-dmeventd.sh      |    2 +-
 test/shell/lvconvert-repair-raid.sh               |    2 +-
 test/shell/lvconvert-repair-replace.sh            |    2 +-
 test/shell/lvconvert-repair-snapshot.sh           |    2 +-
 test/shell/lvconvert-repair-thin.sh               |    2 +-
 test/shell/lvconvert-repair-transient-dmeventd.sh |    2 +-
 test/shell/lvconvert-repair-transient.sh          |    2 +-
 test/shell/lvconvert-repair.sh                    |    2 +-
 test/shell/lvconvert-snapshot.sh                  |    2 +-
 test/shell/lvconvert-thin-external.sh             |    2 +-
 test/shell/lvconvert-thin-raid.sh                 |    2 +-
 test/shell/lvconvert-thin.sh                      |    2 +-
 test/shell/lvconvert-twostep.sh                   |    2 +-
 test/shell/lvcreate-cache.sh                      |    2 +-
 test/shell/lvcreate-large-raid.sh                 |    2 +-
 test/shell/lvcreate-large-raid10.sh               |    2 +-
 test/shell/lvcreate-large.sh                      |    2 +-
 test/shell/lvcreate-mirror.sh                     |    2 +-
 test/shell/lvcreate-missing.sh                    |    2 +-
 test/shell/lvcreate-operation.sh                  |    2 +-
 test/shell/lvcreate-pvtags.sh                     |    2 +-
 test/shell/lvcreate-raid.sh                       |    2 +-
 test/shell/lvcreate-raid10.sh                     |    2 +-
 test/shell/lvcreate-repair.sh                     |    2 +-
 test/shell/lvcreate-signature-wiping.sh           |    2 +-
 test/shell/lvcreate-small-snap.sh                 |    2 +-
 test/shell/lvcreate-striped-mirror.sh             |    2 +-
 test/shell/lvcreate-thin-external.sh              |    2 +-
 test/shell/lvcreate-thin-power2.sh                |    2 +-
 test/shell/lvcreate-thin-snap.sh                  |    2 +-
 test/shell/lvcreate-thin.sh                       |    2 +-
 test/shell/lvcreate-usage.sh                      |    2 +-
 test/shell/lvextend-percent-extents.sh            |    2 +-
 test/shell/lvextend-snapshot-dmeventd.sh          |    2 +-
 test/shell/lvextend-snapshot-policy.sh            |    2 +-
 test/shell/lvextend-thin-metadata-dmeventd.sh     |    2 +-
 test/shell/lvm-init.sh                            |    2 +-
 test/shell/lvmcache-exercise.sh                   |    2 +-
 test/shell/lvmetad-ambiguous.sh                   |    2 +-
 test/shell/lvmetad-disabled.sh                    |    2 +-
 test/shell/lvmetad-dump.sh                        |    2 +-
 test/shell/lvmetad-lvm1.sh                        |    2 +-
 test/shell/lvmetad-no-cluster.sh                  |    2 +-
 test/shell/lvmetad-override.sh                    |    2 +-
 test/shell/lvmetad-pvs.sh                         |    2 +-
 test/shell/lvmetad-pvscan-cache.sh                |    2 +-
 test/shell/lvmetad-pvscan-filter.sh               |    2 +-
 test/shell/lvmetad-pvscan-nomda.sh                |    2 +-
 test/shell/lvmetad-restart.sh                     |    2 +-
 test/shell/lvmetad-test.sh                        |    2 +-
 test/shell/lvmetad-warning.sh                     |    2 +-
 test/shell/lvresize-mirror.sh                     |    2 +-
 test/shell/lvresize-raid.sh                       |    2 +-
 test/shell/lvresize-raid10.sh                     |    2 +-
 test/shell/lvresize-rounding.sh                   |    2 +-
 test/shell/lvresize-thin-external-origin.sh       |    2 +-
 test/shell/lvresize-thin-metadata.sh              |    2 +-
 test/shell/lvresize-usage.sh                      |    2 +-
 test/shell/mda-rollback.sh                        |    2 +-
 test/shell/mdata-strings.sh                       |    2 +-
 test/shell/metadata-balance.sh                    |    2 +-
 test/shell/metadata-dirs.sh                       |    2 +-
 test/shell/metadata.sh                            |    2 +-
 test/shell/mirror-names.sh                        |    2 +-
 test/shell/mirror-vgreduce-removemissing.sh       |    2 +-
 test/shell/name-mangling.sh                       |    2 +-
 test/shell/nomda-missing.sh                       |    2 +-
 test/shell/nomda-restoremissing.sh                |    2 +-
 test/shell/orphan-ondisk.sh                       |    2 +-
 test/shell/pool-labels.sh                         |    2 +-
 test/shell/process-each-duplicate-vgnames.sh      |    2 +-
 test/shell/process-each-lv.sh                     |    2 +-
 test/shell/process-each-vg.sh                     |    2 +-
 test/shell/profiles-thin.sh                       |    2 +-
 test/shell/profiles.sh                            |    2 +-
 test/shell/pv-duplicate-uuid.sh                   |    2 +-
 test/shell/pv-duplicate.sh                        |    2 +-
 test/shell/pv-min-size.sh                         |    2 +-
 test/shell/pv-range-overflow.sh                   |    2 +-
 test/shell/pvchange-usage.sh                      |    2 +-
 test/shell/pvcreate-bootloaderarea.sh             |    2 +-
 test/shell/pvcreate-ff.sh                         |    2 +-
 test/shell/pvcreate-metadata0.sh                  |    2 +-
 test/shell/pvcreate-operation-md.sh               |    2 +-
 test/shell/pvcreate-operation.sh                  |    2 +-
 test/shell/pvcreate-usage.sh                      |    2 +-
 test/shell/pvmove-all-segtypes.sh                 |    2 +-
 test/shell/pvmove-background.sh                   |    2 +-
 test/shell/pvmove-basic.sh                        |    2 +-
 test/shell/pvmove-cache-segtypes.sh               |    2 +-
 test/shell/pvmove-raid-segtypes.sh                |    2 +-
 test/shell/pvmove-restart.sh                      |    2 +-
 test/shell/pvmove-thin-segtypes.sh                |    2 +-
 test/shell/pvremove-thin.sh                       |    2 +-
 test/shell/pvremove-usage.sh                      |    2 +-
 test/shell/read-ahead.sh                          |    2 +-
 test/shell/snapshot-autoumount-dmeventd.sh        |    2 +-
 test/shell/snapshot-lvm1.sh                       |    2 +-
 test/shell/snapshot-maxsize.sh                    |    2 +-
 test/shell/snapshot-merge.sh                      |    2 +-
 test/shell/snapshot-reactivate.sh                 |    2 +-
 test/shell/snapshot-usage.sh                      |    2 +-
 test/shell/snapshots-of-mirrors.sh                |    2 +-
 test/shell/stray-device-node.sh                   |    2 +-
 test/shell/tags.sh                                |    2 +-
 test/shell/test-partition.sh                      |    2 +-
 test/shell/thin-autoumount-dmeventd.sh            |    2 +-
 test/shell/thin-defaults.sh                       |    2 +-
 test/shell/thin-merge.sh                          |    2 +-
 test/shell/thin-restore.sh                        |    2 +-
 test/shell/thin-vglock.sh                         |    2 +-
 test/shell/topology-support.sh                    |    2 +-
 test/shell/unknown-segment.sh                     |    2 +-
 test/shell/unlost-pv.sh                           |    2 +-
 test/shell/vg-name-from-env.sh                    |    2 +-
 test/shell/vgcfgbackup-usage.sh                   |    2 +-
 test/shell/vgchange-many.sh                       |    2 +-
 test/shell/vgchange-maxlv.sh                      |    2 +-
 test/shell/vgchange-partial.sh                    |    2 +-
 test/shell/vgchange-sysinit.sh                    |    2 +-
 test/shell/vgchange-usage.sh                      |    2 +-
 test/shell/vgck.sh                                |    2 +-
 test/shell/vgcreate-usage.sh                      |    2 +-
 test/shell/vgextend-restoremissing.sh             |    2 +-
 test/shell/vgextend-usage.sh                      |    2 +-
 test/shell/vgimportclone.sh                       |    2 +-
 test/shell/vgmerge-operation.sh                   |    2 +-
 test/shell/vgmerge-usage.sh                       |    2 +-
 test/shell/vgreduce-removemissing-snapshot.sh     |    2 +-
 test/shell/vgreduce-usage.sh                      |    2 +-
 test/shell/vgremove-corrupt-vg.sh                 |    2 +-
 test/shell/vgrename-usage.sh                      |    2 +-
 test/shell/vgsplit-operation.sh                   |    2 +-
 test/shell/vgsplit-raid.sh                        |    2 +-
 test/shell/vgsplit-stacked.sh                     |    2 +-
 test/shell/vgsplit-thin.sh                        |    2 +-
 test/shell/vgsplit-usage.sh                       |    2 +-
 test/shell/zero-usage.sh                          |    2 +-
 172 files changed, 272 insertions(+), 272 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 5ac045f..46aeaec 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -156,7 +156,7 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	mv $@-t $@
 
 LIB = lib/not lib/invalid lib/fail lib/should lib/harness \
-      lib/check lib/aux lib/test lib/utils lib/get lib/lvm-wrapper \
+      lib/check lib/aux lib/inittest lib/utils lib/get lib/lvm-wrapper \
       lib/paths
 
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
new file mode 100644
index 0000000..731cd7a
--- /dev/null
+++ b/test/lib/inittest.sh
@@ -0,0 +1,102 @@
+#!/usr/bin/env bash
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# sanitize the environment
+LANG=C
+LC_ALL=C
+TZ=UTC
+
+# Put script name into variable, so it can used in external scripts
+TESTNAME=${0##*/}
+# Nice debug message
+PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
+export TESTNAME PS4
+
+unset CDPATH
+
+# grab some common utilities
+. lib/utils
+
+TESTOLDPWD=$(pwd)
+COMMON_PREFIX="LVMTEST"
+PREFIX="${COMMON_PREFIX}$$"
+
+TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-$TESTOLDPWD}" "$PREFIX.XXXXXXXXXX") || \
+	die "failed to create temporary directory in ${LVM_TEST_DIR:-$TESTOLDPWD}"
+RUNNING_DMEVENTD=$(pgrep dmeventd) || true
+
+export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
+
+test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
+trap 'aux teardown' EXIT # don't forget to clean up
+
+cd "$TESTDIR"
+
+if test -n "$LVM_TEST_FLAVOUR"; then
+	touch flavour_overrides
+	env | grep ^${LVM_TEST_FLAVOUR} | while read var; do
+		(echo -n "export "; echo $var | sed -e s,^${LVM_TEST_FLAVOUR}_,,) >> flavour_overrides
+	done
+	. flavour_overrides
+fi
+
+DM_DEFAULT_NAME_MANGLING_MODE=none
+DM_DEV_DIR="$TESTDIR/dev"
+LVM_SYSTEM_DIR="$TESTDIR/etc"
+mkdir "$LVM_SYSTEM_DIR" "$TESTDIR/lib" "$DM_DEV_DIR"
+if test -n "$LVM_TEST_DEVDIR" ; then
+	DM_DEV_DIR=$LVM_TEST_DEVDIR
+else
+	mknod "$DM_DEV_DIR/testnull" c 1 3 || die "mknod failed";
+	echo >"$DM_DEV_DIR/testnull" || \
+		die "Filesystem does support devices in $DM_DEV_DIR (mounted with nodev?)"
+	mkdir "$DM_DEV_DIR/mapper"
+fi
+
+# abort on the internal dm errors in the tests (allowing test user override)
+DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
+
+export DM_DEFAULT_NAME_MANGLING_MODE DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
+
+echo "$TESTNAME" >TESTNAME
+
+echo "Kernel is $(uname -a)"
+# Report SELinux mode
+if which getenforce &>/dev/null ; then
+	echo "Selinux mode is \"$(getenforce 2>/dev/null)\"."
+else
+	echo "Selinux mode is not installed."
+fi
+
+# Setting up symlink from $i to $TESTDIR/lib
+find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
+	-exec ln -s -t lib "{}" +
+find "$abs_top_builddir/test/lib" ! \( -name '*.sh' -o -name '*.[cdo]' \
+	-o -name '*~' \)  -exec ln -s -t lib "{}" +
+
+# Set vars from utils now that we have TESTDIR/PREFIX/...
+prepare_test_vars
+
+test -n "$BASH" && set -eE -o pipefail
+
+aux lvmconf
+aux prepare_clvmd
+test -n "$LVM_TEST_LVMETAD" && {
+	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
+	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
+	aux prepare_lvmetad
+}
+
+# Vars for harness
+echo "@TESTDIR=$TESTDIR"
+echo "@PREFIX=$PREFIX"
+
+set -vx
diff --git a/test/lib/test.sh b/test/lib/test.sh
deleted file mode 100644
index 731cd7a..0000000
--- a/test/lib/test.sh
+++ /dev/null
@@ -1,102 +0,0 @@
-#!/usr/bin/env bash
-# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-
-# sanitize the environment
-LANG=C
-LC_ALL=C
-TZ=UTC
-
-# Put script name into variable, so it can used in external scripts
-TESTNAME=${0##*/}
-# Nice debug message
-PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
-export TESTNAME PS4
-
-unset CDPATH
-
-# grab some common utilities
-. lib/utils
-
-TESTOLDPWD=$(pwd)
-COMMON_PREFIX="LVMTEST"
-PREFIX="${COMMON_PREFIX}$$"
-
-TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-$TESTOLDPWD}" "$PREFIX.XXXXXXXXXX") || \
-	die "failed to create temporary directory in ${LVM_TEST_DIR:-$TESTOLDPWD}"
-RUNNING_DMEVENTD=$(pgrep dmeventd) || true
-
-export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
-
-test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR
-trap 'aux teardown' EXIT # don't forget to clean up
-
-cd "$TESTDIR"
-
-if test -n "$LVM_TEST_FLAVOUR"; then
-	touch flavour_overrides
-	env | grep ^${LVM_TEST_FLAVOUR} | while read var; do
-		(echo -n "export "; echo $var | sed -e s,^${LVM_TEST_FLAVOUR}_,,) >> flavour_overrides
-	done
-	. flavour_overrides
-fi
-
-DM_DEFAULT_NAME_MANGLING_MODE=none
-DM_DEV_DIR="$TESTDIR/dev"
-LVM_SYSTEM_DIR="$TESTDIR/etc"
-mkdir "$LVM_SYSTEM_DIR" "$TESTDIR/lib" "$DM_DEV_DIR"
-if test -n "$LVM_TEST_DEVDIR" ; then
-	DM_DEV_DIR=$LVM_TEST_DEVDIR
-else
-	mknod "$DM_DEV_DIR/testnull" c 1 3 || die "mknod failed";
-	echo >"$DM_DEV_DIR/testnull" || \
-		die "Filesystem does support devices in $DM_DEV_DIR (mounted with nodev?)"
-	mkdir "$DM_DEV_DIR/mapper"
-fi
-
-# abort on the internal dm errors in the tests (allowing test user override)
-DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
-
-export DM_DEFAULT_NAME_MANGLING_MODE DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
-
-echo "$TESTNAME" >TESTNAME
-
-echo "Kernel is $(uname -a)"
-# Report SELinux mode
-if which getenforce &>/dev/null ; then
-	echo "Selinux mode is \"$(getenforce 2>/dev/null)\"."
-else
-	echo "Selinux mode is not installed."
-fi
-
-# Setting up symlink from $i to $TESTDIR/lib
-find "$abs_top_builddir/daemons/dmeventd/plugins/" -name '*.so' \
-	-exec ln -s -t lib "{}" +
-find "$abs_top_builddir/test/lib" ! \( -name '*.sh' -o -name '*.[cdo]' \
-	-o -name '*~' \)  -exec ln -s -t lib "{}" +
-
-# Set vars from utils now that we have TESTDIR/PREFIX/...
-prepare_test_vars
-
-test -n "$BASH" && set -eE -o pipefail
-
-aux lvmconf
-aux prepare_clvmd
-test -n "$LVM_TEST_LVMETAD" && {
-	export LVM_LVMETAD_SOCKET="$TESTDIR/lvmetad.socket"
-	export LVM_LVMETAD_PIDFILE="$TESTDIR/lvmetad.pid"
-	aux prepare_lvmetad
-}
-
-# Vars for harness
-echo "@TESTDIR=$TESTDIR"
-echo "@PREFIX=$PREFIX"
-
-set -vx
diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index 83e6efe..7ad4d9f 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 lvm version
 
diff --git a/test/shell/activate-minor.sh b/test/shell/activate-minor.sh
index 1cebda4..1c5386c 100644
--- a/test/shell/activate-minor.sh
+++ b/test/shell/activate-minor.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 # Just skip this test if minor is already in use...
 dmsetup info | tee info
diff --git a/test/shell/activate-missing-segment.sh b/test/shell/activate-missing-segment.sh
index afda20f..5f43c72 100644
--- a/test/shell/activate-missing-segment.sh
+++ b/test/shell/activate-missing-segment.sh
@@ -16,7 +16,7 @@
 #   instead lvconvert --repair them?)
 # - linear LVs with bits missing are not activated
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 2
 
diff --git a/test/shell/activate-missing.sh b/test/shell/activate-missing.sh
index fd57e1a..8e2ff1e 100644
--- a/test/shell/activate-missing.sh
+++ b/test/shell/activate-missing.sh
@@ -16,7 +16,7 @@
 #   instead lvconvert --repair them?)
 # - linear LVs with bits missing are not activated
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 4
 
diff --git a/test/shell/activate-partial.sh b/test/shell/activate-partial.sh
index cbfa433..0b5d1b6 100644
--- a/test/shell/activate-partial.sh
+++ b/test/shell/activate-partial.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 3
 
diff --git a/test/shell/activation-skip.sh b/test/shell/activation-skip.sh
index 76680b2..ca562a7 100644
--- a/test/shell/activation-skip.sh
+++ b/test/shell/activation-skip.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 # Test skip activation flag  -k|--setactivationskip
 
diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index b288ad8..4a9f12e 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -13,7 +13,7 @@
 export LVM_CLVMD_BINARY=clvmd
 export LVM_BINARY=lvm
 
-. lib/test
+. lib/inittest
 
 # only clvmd based test, skip otherwise
 test -e LOCAL_CLVMD || skip
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index d7dde5b..c84c967 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -14,7 +14,7 @@
 # to improve code coverage
 #
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 5
 get_devs
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 525f106..a2cac52 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -13,7 +13,7 @@
 # test support of thin discards
 #
 
-. lib/test
+. lib/inittest
 
 #
 # Main
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index e27d426..366b4d2 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_dmeventd
 
diff --git a/test/shell/dumpconfig.sh b/test/shell/dumpconfig.sh
index a16f753..f52157f 100644
--- a/test/shell/dumpconfig.sh
+++ b/test/shell/dumpconfig.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 flatten() {
 	cat > flatten.config
diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index a7e3593..61e282b 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -11,7 +11,7 @@
 
 # Basic usage of zero target
 
-. lib/test
+. lib/inittest
 
 which md5sum || skip
 
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 04b659f..612d2b7 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -11,7 +11,7 @@
 
 test_description='Exercise fsadm filesystem resize'
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 1 100
 
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 06bd310..69d1f33 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 3 12
 
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index d916a41..fbd4af7 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -13,7 +13,7 @@
 # tests functionality of lvs, pvs, vgs, *display tools
 #
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 5
 get_devs
diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index aaf2e0b..e05fa50 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -11,7 +11,7 @@
 
 test_description='test some blocking / non-blocking multi-vg operations'
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 3
 test -e LOCAL_CLVMD && skip
diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index e7d15ef..993175f 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -12,7 +12,7 @@
 # Test parallel use of lvm commands and check locks aren't dropped
 # RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1049296
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext3 || skip
 
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index 37a6e1b..f28e486 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 # FIXME RESYNC doesn't work in cluster with exclusive activation
 # seriously broken!
diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
index 3c112bb..8014abd 100644
--- a/test/shell/lvchange-partial-raid10.sh
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux have_raid 1 3 2 || skip
 
diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index 3db1b4f..c65c07b 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 
 aux prepare_vg 4
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index a229154..e35f4de 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 # Writemostly has been in every version since the begining
 # Device refresh in 1.5.1 upstream and 1.3.4 < x < 1.4.0 in RHEL6
diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index b5fdfb4..18af83f 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -11,7 +11,7 @@
 
 # test activation race for raid's --syncaction check
 
-. lib/test
+. lib/inittest
 
 # Proper mismatch count 1.5.2+ upstream, 1.3.5 < x < 1.4.0 in RHEL6
 aux have_raid 1 3 5 &&
diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index c6fd813..cb9be53 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux have_thin 1 0 0 || skip
 
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 28258b2..6fcff70 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 log_name_to_count() {
 	case "$1"  in
diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index 3b30738..18618fd 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -11,7 +11,7 @@
 
 # Demonstrate problem when upconverting and cutting leg in clvmd
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 3
 
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 8c0c72e..d8f057a 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 5 10
 # proper DEVRANGE needs to be set according to extent size
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index e17d90e..6f17303 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 get_image_pvs() {
 	local d
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index e9b0ef8..c4b92f1 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 get_image_pvs() {
 	local d
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 38f8ed5..1ead128 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 get_image_pvs() {
 	local d
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index 472c812..eed0819 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext2 || skip
 aux mirror_recovery_works || skip
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index 9d71b66..ace52fc 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 4
 aux lvmconf 'allocation/maximise_cling = 0'
diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index 6766faa..eeb424e 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext3 || skip
 aux have_raid 1 3 0 || skip
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 8ba27b8..4f0175a 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux have_raid 1 3 0 || skip
 aux raid456_replace_works || skip
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index c02d2ac..3c0dc53 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 6
 aux lvmconf 'allocation/maximise_cling = 0'
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 77fd217..473d561 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 5
 aux lvmconf 'allocation/maximise_cling = 0'
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 8b0f117..6aa5590 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -12,7 +12,7 @@
 
 # Test repairing of broken thin pool metadata
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext2 || skip
 
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 1cda215..5347d88 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux mirror_recovery_works || skip
 aux prepare_vg 5
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 21df1ef..99018ef 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux mirror_recovery_works || skip
 aux prepare_vg 5
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index db24710..91437a6 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 recreate_vg_()
 {
diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index e38d69b..f59bb7b 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -12,7 +12,7 @@
 
 # Test various supported conversion of snapshot
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 1
 
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 5d52e60..676851e 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -12,7 +12,7 @@
 
 # Test conversion to thin external origin
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext2 || skip
 which fsck || skip
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index ae3d2ef..7e5efbd 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux have_thin 1 0 0 || skip
 aux have_raid 1 4 0 || skip
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 2ce43b8..4a200bb 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 prepare_lvs()
 {
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index 6b1dd51..788b751 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 4
 
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 1c438e7..c4b4a75 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux have_cache 1 3 0 || skip
 
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 57a7765..286b068 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -11,7 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. lib/test
+. lib/inittest
 
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 5a15ee0..3c6ddcf 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -11,7 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. lib/test
+. lib/inittest
 
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index 401191b..24fccb1 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -11,7 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. lib/test
+. lib/inittest
 
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index 6b54081..a151126 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 aux prepare_vg 5 80
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
diff --git a/test/shell/lvcreate-missing.sh b/test/shell/lvcreate-missing.sh
index dfc6e65..2b74052 100644
--- a/test/shell/lvcreate-missing.sh
+++ b/test/shell/lvcreate-missing.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 2
 init_udev_transaction
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 2aa96d2..fac7219 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -11,7 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. lib/test
+. lib/inittest
 
 cleanup_lvs() {
 	lvremove -ff $vg
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index 1df07fc..b7c814f 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 3
 aux lvmconf 'allocation/maximise_cling = 0'
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 76a606f..6bbc3fe 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 lv_devices() {
 	test $3 -eq $(get lv_devices $1/$2 | wc -w)
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index ae02ab2..e334bd1 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 lv_devices() {
 	test $3 -eq $(get lv_devices $1/$2 | wc -w)
diff --git a/test/shell/lvcreate-repair.sh b/test/shell/lvcreate-repair.sh
index 8971536..1690565 100644
--- a/test/shell/lvcreate-repair.sh
+++ b/test/shell/lvcreate-repair.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA	02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 3
 
diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index f45a372..388c542 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -11,7 +11,7 @@
 
 # 'Exercise signature wiping during lvcreate'
 
-. lib/test
+. lib/inittest
 
 init_lv_() {
 	mkswap "$DM_DEV_DIR/$vg/$lv1"
diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index 33532db..b29c5f8 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs
 
diff --git a/test/shell/lvcreate-striped-mirror.sh b/test/shell/lvcreate-striped-mirror.sh
index f02c658..eaa7fb8 100644
--- a/test/shell/lvcreate-striped-mirror.sh
+++ b/test/shell/lvcreate-striped-mirror.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 9
 
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index 1e5b333..74e5521 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -12,7 +12,7 @@
 
 # Test creation of thin snapshots using external origin
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext2 || skip
 which fsck || skip
diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index e1effa4..ed62db3 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -13,7 +13,7 @@
 # test support for non-power-of-2 thin chunk size
 #
 
-. lib/test
+. lib/inittest
 
 #
 # Main
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 6a6a842..6f29a28 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 check_lv_field_modules_()
 {
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 7ea4fcf..9712652 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -13,7 +13,7 @@
 # test currently needs to drop
 # 'return NULL' in _lv_create_an_lv after log_error("Can't create %s without using "
 
-. lib/test
+. lib/inittest
 
 check_lv_field_modules_()
 {
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 2a0e0a6..7ae6d25 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -11,7 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 4
 aux pvcreate --metadatacopies 0 "$dev1"
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index 34654a0..9b5dc5d 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -11,7 +11,7 @@
 
 # 'Check extents percentage arguments'
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 2 128
 vgcreate $vg $(cat DEVICES)
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index 2bf552d..af8a927 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 extend() {
 	lvextend --use-policies --config "activation { snapshot_autoextend_threshold = $1 }" $vg/snap
diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index f396765..210e2fb 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext2 || skip
 
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 6e03d9d..44144c6 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -10,7 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # Test autoextension of thin metadata volume
-. lib/test
+. lib/inittest
 
 meta_percent_() {
 	get lv_field $vg/pool metadata_percent | cut -d. -f1
diff --git a/test/shell/lvm-init.sh b/test/shell/lvm-init.sh
index 8eb7814..c3f7ecf 100644
--- a/test/shell/lvm-init.sh
+++ b/test/shell/lvm-init.sh
@@ -13,7 +13,7 @@
 # tests lvm initialization, and especially negative tests of error paths
 #
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 5
 
diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index b7c584b..2aaf650 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 5
 
diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
index 6ff055a..2e7c6c5 100644
--- a/test/shell/lvmetad-ambiguous.sh
+++ b/test/shell/lvmetad-ambiguous.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_LVMETAD || skip
 
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index c344d7f..acb5f82 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_LVMETAD || skip
 kill $(cat LOCAL_LVMETAD)
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index 9c9cd2b..0c3df3b 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 test -e LOCAL_LVMETAD || skip
 
 aux prepare_pvs 2
diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index dcff55b..3745dd0 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_LVMETAD || skip
 aux prepare_devs 2
diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
index 0c53822..85c1ea9 100644
--- a/test/shell/lvmetad-no-cluster.sh
+++ b/test/shell/lvmetad-no-cluster.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_CLVMD || skip
 aux prepare_vg 2
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index fe11658..ff4ad18 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_LVMETAD || skip
 aux prepare_pvs 2
diff --git a/test/shell/lvmetad-pvs.sh b/test/shell/lvmetad-pvs.sh
index 80b421c..7f25490 100644
--- a/test/shell/lvmetad-pvs.sh
+++ b/test/shell/lvmetad-pvs.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 1 20000
 pvs $(cat DEVICES) | grep "$dev1"
diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index 7b161aa..d309e82 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_LVMETAD || skip
 
diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index 73690a0..a3af1b2 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_LVMETAD || skip
 
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index 04c9c6b..c55cafb 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_LVMETAD || skip
 kill $(cat LOCAL_LVMETAD)
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
index 6e25f8a..6377c57 100644
--- a/test/shell/lvmetad-restart.sh
+++ b/test/shell/lvmetad-restart.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_LVMETAD || skip
 aux prepare_pvs 2
diff --git a/test/shell/lvmetad-test.sh b/test/shell/lvmetad-test.sh
index 934e985..6ebd9ad 100644
--- a/test/shell/lvmetad-test.sh
+++ b/test/shell/lvmetad-test.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
index 365f70f..1c6c62b 100644
--- a/test/shell/lvmetad-warning.sh
+++ b/test/shell/lvmetad-warning.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_LVMETAD || skip
 aux prepare_pvs 2
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index b4bbb04..0b9f526 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 5
 
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index d5288f8..8c7d909 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux have_raid 1 3 0 || skip
 
diff --git a/test/shell/lvresize-raid10.sh b/test/shell/lvresize-raid10.sh
index 42cfeb4..aead385 100644
--- a/test/shell/lvresize-raid10.sh
+++ b/test/shell/lvresize-raid10.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux have_raid 1 3 0 || skip
 
diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index e5425a2..d06dcf1 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 3 22
 
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index 3499196..e4463e2 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -10,7 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # Test resize of thin volume with external origin
-. lib/test
+. lib/inittest
 
 aux have_thin 1 2 0 || skip
 
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index e62d8b6..a034d07 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux have_thin 1 10 0 || skip
 
diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index 65f6b1e..a235838 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 2 80
 
diff --git a/test/shell/mda-rollback.sh b/test/shell/mda-rollback.sh
index aebbfb6..fa8e376 100644
--- a/test/shell/mda-rollback.sh
+++ b/test/shell/mda-rollback.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 3
 
diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index 0102d4b..a1598ad 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -11,7 +11,7 @@
 
 # 'Test for proper escaping of strings in metadata (bz431474)'
 
-. lib/test
+. lib/inittest
 
 # For udev impossible to create
 test "$LVM_TEST_DEVDIR" = "/dev" && skip
diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index 5efc412..5ee0eba 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 6
 
diff --git a/test/shell/metadata-dirs.sh b/test/shell/metadata-dirs.sh
index 852ce35..f4a41bc 100644
--- a/test/shell/metadata-dirs.sh
+++ b/test/shell/metadata-dirs.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 3
 
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index b02e74a..3adb684 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 5
 
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index f5d1322..8094798 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -12,7 +12,7 @@
 
 test_description="check namings of mirrored LV"
 
-. lib/test
+. lib/inittest
 
 # ---------------------------------------------------------------------
 # Utilities
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 340a333..62847ae 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -12,7 +12,7 @@
 
 test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
 
-. lib/test
+. lib/inittest
 
 lv_is_on_ ()
 {
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index fe54de4..ee34994 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 # This test is not using any lvm command
 # so skip duplicate CLMVD and lvmetad test
diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index 946eecd..7de458b 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 4
 pvcreate "$dev1" "$dev2"
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index 3dcd41e..01a77d0 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 3
 
diff --git a/test/shell/orphan-ondisk.sh b/test/shell/orphan-ondisk.sh
index 266d74b..8395073 100644
--- a/test/shell/orphan-ondisk.sh
+++ b/test/shell/orphan-ondisk.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 2
 vgreduce $vg "$dev1" 2>&1 | not grep -i 'parse error'
diff --git a/test/shell/pool-labels.sh b/test/shell/pool-labels.sh
index b5cbbdc..a2163e8 100644
--- a/test/shell/pool-labels.sh
+++ b/test/shell/pool-labels.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 # lvmetad does not handle pool labels so skip test.
 test ! -e LOCAL_LVMETAD || skip
diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index 5138d22..5867fd1 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -7,7 +7,7 @@
 
 test_description='Test vgs with duplicate vg names'
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 2
 
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index 207f1ba..0260951 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -11,7 +11,7 @@
 
 test_description='Exercise toollib process_each_lv'
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 10
 
diff --git a/test/shell/process-each-vg.sh b/test/shell/process-each-vg.sh
index 90c0dbc..e8690f5 100644
--- a/test/shell/process-each-vg.sh
+++ b/test/shell/process-each-vg.sh
@@ -11,7 +11,7 @@
 
 test_description='Exercise toollib process_each_vg'
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 6
 
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 25c12eb..704ef2d 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -13,7 +13,7 @@
 # test thin profile functionality
 #
 
-. lib/test
+. lib/inittest
 
 DEV_SIZE=32
 
diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index 49b8b9c..e054c88 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -13,7 +13,7 @@
 # test basic profile functionality
 #
 
-. lib/test
+. lib/inittest
 
 MSG_FAILED_TO_APPLY_CMD_PROFILE="Failed to apply command profile"
 MSG_IGNORING_INVALID_CMD_PROFILE="Ignoring invalid command profile"
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index cc5f56b..1763142 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -10,7 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # Test 'Found duplicate' is shown
-. lib/test
+. lib/inittest
 
 aux prepare_devs 3
 
diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
index f315d86..ede9600 100644
--- a/test/shell/pv-duplicate.sh
+++ b/test/shell/pv-duplicate.sh
@@ -11,7 +11,7 @@
 
 # 'Exercise duplicate metadata diagnostics'
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 3
 
diff --git a/test/shell/pv-min-size.sh b/test/shell/pv-min-size.sh
index 59250cf..d29e94c 100644
--- a/test/shell/pv-min-size.sh
+++ b/test/shell/pv-min-size.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 # use small default size  - 512KB
 aux lvmconf 'devices/pv_min_size = 512'
diff --git a/test/shell/pv-range-overflow.sh b/test/shell/pv-range-overflow.sh
index 0f353dd..4caee02 100644
--- a/test/shell/pv-range-overflow.sh
+++ b/test/shell/pv-range-overflow.sh
@@ -11,7 +11,7 @@
 
 # 'Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 2
 
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index 71388de..ac63aec 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -11,7 +11,7 @@
 
 # 'Test pvchange option values'
 
-. lib/test
+. lib/inittest
 
 check_changed_uuid_() {
 	test "$1" != "$(get pv_field "$2" uuid)" || die "UUID has not changed!"
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index 0fa6022..42349e4 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -11,7 +11,7 @@
 
 test_description='Test pvcreate bootloader area support'
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 1
 aux lvmconf 'global/suffix=0'
diff --git a/test/shell/pvcreate-ff.sh b/test/shell/pvcreate-ff.sh
index 72caf63..1cbf0ff 100644
--- a/test/shell/pvcreate-ff.sh
+++ b/test/shell/pvcreate-ff.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 2
 pvcreate "$dev1"
diff --git a/test/shell/pvcreate-metadata0.sh b/test/shell/pvcreate-metadata0.sh
index 01cb6be..263bd88 100644
--- a/test/shell/pvcreate-metadata0.sh
+++ b/test/shell/pvcreate-metadata0.sh
@@ -15,7 +15,7 @@
 #
 # 'Test pvcreate without metadata on all pvs'
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 2 128
 
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 9cad745..f959c0b 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 # skip this test if mdadm or sfdisk (or others) aren't available
 which mdadm || skip
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index e446b62..e72f2b9 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux lvmconf 'devices/md_component_detection = 1'
 
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 251746d..48d2ceb 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -12,7 +12,7 @@
 test_description='Test pvcreate option values'
 PAGESIZE=$(getconf PAGESIZE)
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 4
 
diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index 130a4e9..457054b 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -11,7 +11,7 @@
 
 test_description="ensure pvmove works with all common segment types"
 
-. lib/test
+. lib/inittest
 
 which md5sum || skip
 
diff --git a/test/shell/pvmove-background.sh b/test/shell/pvmove-background.sh
index f38d723..0cd5dd3 100644
--- a/test/shell/pvmove-background.sh
+++ b/test/shell/pvmove-background.sh
@@ -11,7 +11,7 @@
 
 # Check pvmove behavior when it's progress and machine is rebooted
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 3
 
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index 911bbf0..e58f5bf 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -12,7 +12,7 @@
 
 test_description="ensure that pvmove works with basic options"
 
-. lib/test
+. lib/inittest
 
 which md5sum || skip
 
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index c9f2078..0c1020e 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -11,7 +11,7 @@
 
 test_description="ensure pvmove works with the cache segment types"
 
-. lib/test
+. lib/inittest
 
 # pvmove fails when a RAID LV is the origin of a cache LV
 # pvmoving cache types is currently disabled in tools/pvmove.c
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index f3f5cd5..dd12c1b 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -11,7 +11,7 @@
 
 test_description="ensure pvmove works with raid segment types"
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_CLVMD && skip
 which md5sum || skip
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index b827632..9f30cf7 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -11,7 +11,7 @@
 
 # Check pvmove behavior when it's progress and machine is rebooted
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 3 60
 
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index 4bd3b29..7819e6c 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -11,7 +11,7 @@
 
 test_description="ensure pvmove works with thin segment types"
 
-. lib/test
+. lib/inittest
 test -e LOCAL_CLVMD && skip
 which md5sum || skip
 
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index e8af2af..5bfb880 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -12,7 +12,7 @@
 # Checks we are not reading our own devices
 # https://bugzilla.redhat.com/show_bug.cgi?id=1064374
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg
 
diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index 52f04b8..3ebfd15 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 3
 pvcreate "$dev1"
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 26335f0..764bef1 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -15,7 +15,7 @@
 
 test_description='Test read-ahead functionality'
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 5
 
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index ddc41f7..9d5b8c5 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -11,7 +11,7 @@
 
 # no automatic extensions please
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext2 || skip
 
diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
index 642dd6f..f6afe14 100644
--- a/test/shell/snapshot-lvm1.sh
+++ b/test/shell/snapshot-lvm1.sh
@@ -12,7 +12,7 @@
 # regression test for lvmetad reporting error:
 # Internal error: LV snap_with_lvm1_meta (00000000000000000000000000000001) missing from preload metadata
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 2
 
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index e1380c6..f5be5a5 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -12,7 +12,7 @@
 # Testing calculation of snapshot space
 # https://bugzilla.redhat.com/show_bug.cgi?id=1035871
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 1
 
diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 8760e53..bebc9de 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext3 || skip
 
diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
index 28e1d62..0fbdc62 100644
--- a/test/shell/snapshot-reactivate.sh
+++ b/test/shell/snapshot-reactivate.sh
@@ -15,7 +15,7 @@
 # is triggered by kernel 3.14-rc[1..5]
 # http://www.redhat.com/archives/dm-devel/2014-March/msg00005.html
 #
-. lib/test
+. lib/inittest
 
 # Snapshot should remain unmodified
 check_s_() {
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index fd43650..3fc40e3 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -11,7 +11,7 @@
 
 # no automatic extensions please
 
-. lib/test
+. lib/inittest
 
 MKFS=mkfs.ext2
 which $MKFS || skip
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index ac5cf85..07b163d 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 4
 
diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index cd6525f..0ff4796 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 3
 cp -r "$dev1" "$DM_DEV_DIR/stray"
diff --git a/test/shell/tags.sh b/test/shell/tags.sh
index ee2f610..bc66d15 100644
--- a/test/shell/tags.sh
+++ b/test/shell/tags.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 4
 
diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index f7e91b8..af04b4e 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -17,7 +17,7 @@
 
 LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
 
-. lib/test
+. lib/inittest
 
 which sfdisk || skip
 
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index bbffe8a..a77ad08 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -16,7 +16,7 @@ is_dir_mounted_()
 	cat /proc/mounts | sed 's:\\040: :g' | grep "$1"
 }
 
-. lib/test
+. lib/inittest
 
 #
 # Main
diff --git a/test/shell/thin-defaults.sh b/test/shell/thin-defaults.sh
index 677d2f1..4f873cc 100644
--- a/test/shell/thin-defaults.sh
+++ b/test/shell/thin-defaults.sh
@@ -11,7 +11,7 @@
 
 # test defaults entered through lvm.conf
 
-. lib/test
+. lib/inittest
 
 #
 # Main
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 60234a6..d3275dd 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -11,7 +11,7 @@
 
 # test merge of thin snapshot
 
-. lib/test
+. lib/inittest
 
 MKFS=mkfs.ext2
 which $MKFS  || skip
diff --git a/test/shell/thin-restore.sh b/test/shell/thin-restore.sh
index 7580ae4..fd4118f 100644
--- a/test/shell/thin-restore.sh
+++ b/test/shell/thin-restore.sh
@@ -11,7 +11,7 @@
 
 # test restore operation of thin pool metadata
 
-. lib/test
+. lib/inittest
 
 #
 # Main
diff --git a/test/shell/thin-vglock.sh b/test/shell/thin-vglock.sh
index 083fcd8..fe1ee11 100644
--- a/test/shell/thin-vglock.sh
+++ b/test/shell/thin-vglock.sh
@@ -12,7 +12,7 @@
 # Test locking works and doesn't update metadata
 # RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=1063542
 
-. lib/test
+. lib/inittest
 
 MKFS=mkfs.ext2
 which $MKFS || skip
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index 4fa73be..a1af6d7 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 which mkfs.ext3 || skip
 
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index b4a5dfd..b07e1b5 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 4
 
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index 307a71b..980c451 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 check_() {
 	# vgscan needs --cache option for direct scan if lvmetad is used
diff --git a/test/shell/vg-name-from-env.sh b/test/shell/vg-name-from-env.sh
index c399bb6..67ad5c5 100644
--- a/test/shell/vg-name-from-env.sh
+++ b/test/shell/vg-name-from-env.sh
@@ -7,7 +7,7 @@
 
 test_description='Test the vg name for an lv from env var'
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 2
 
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index bc09b5b..eb36983 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 4
 
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index 491c8b1..16e0516 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -10,7 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # Check perfomance of activation and deactivation
-. lib/test
+. lib/inittest
 
 # FIXME: lvmetad fails with i.e. 1500 device on memory failure...
 
diff --git a/test/shell/vgchange-maxlv.sh b/test/shell/vgchange-maxlv.sh
index 99a6a79..35ce5d6 100644
--- a/test/shell/vgchange-maxlv.sh
+++ b/test/shell/vgchange-maxlv.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_dmeventd
 aux prepare_pvs 3
diff --git a/test/shell/vgchange-partial.sh b/test/shell/vgchange-partial.sh
index ad99460..7fd9840 100644
--- a/test/shell/vgchange-partial.sh
+++ b/test/shell/vgchange-partial.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 2
 
diff --git a/test/shell/vgchange-sysinit.sh b/test/shell/vgchange-sysinit.sh
index 49c3bde..4debf42 100644
--- a/test/shell/vgchange-sysinit.sh
+++ b/test/shell/vgchange-sysinit.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 test -e LOCAL_CLVMD && skip
 
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 0d57913..54734c1 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -11,7 +11,7 @@
 
 test_description='Exercise some vgchange diagnostics'
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 4
 
diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index b6858cb..629b6e7 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 3
 lvcreate -n blabla -L 1 $vg
diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index bf7d3b3..a1d178d 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -11,7 +11,7 @@
 
 test_description='Exercise some vgcreate diagnostics'
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 3
 pvcreate "$dev1" "$dev2"
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 8812c8c..7b7748f 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 3
 
diff --git a/test/shell/vgextend-usage.sh b/test/shell/vgextend-usage.sh
index 0e347c3..93401f0 100644
--- a/test/shell/vgextend-usage.sh
+++ b/test/shell/vgextend-usage.sh
@@ -13,7 +13,7 @@
 # Exercise various vgextend commands
 #
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 5
 
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 29c172e..c3d7e52 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 2
 
diff --git a/test/shell/vgmerge-operation.sh b/test/shell/vgmerge-operation.sh
index 0c0517c..261953e 100644
--- a/test/shell/vgmerge-operation.sh
+++ b/test/shell/vgmerge-operation.sh
@@ -11,7 +11,7 @@
 
 test_description='Test vgmerge operation'
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 4 64
 
diff --git a/test/shell/vgmerge-usage.sh b/test/shell/vgmerge-usage.sh
index ef613d7..d8fa09c 100644
--- a/test/shell/vgmerge-usage.sh
+++ b/test/shell/vgmerge-usage.sh
@@ -11,7 +11,7 @@
 
 # 'Test vgmerge command options for validity'
 
-. lib/test
+. lib/inittest
 
 aux prepare_pvs 4
 
diff --git a/test/shell/vgreduce-removemissing-snapshot.sh b/test/shell/vgreduce-removemissing-snapshot.sh
index c587b17..1bea397 100644
--- a/test/shell/vgreduce-removemissing-snapshot.sh
+++ b/test/shell/vgreduce-removemissing-snapshot.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 exit 0
 
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index fab7496..52c5f36 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 4
 
diff --git a/test/shell/vgremove-corrupt-vg.sh b/test/shell/vgremove-corrupt-vg.sh
index 9e750ac..f709e4e 100644
--- a/test/shell/vgremove-corrupt-vg.sh
+++ b/test/shell/vgremove-corrupt-vg.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_vg 3
 lvcreate -n blabla -L 1 $vg -an --zero n
diff --git a/test/shell/vgrename-usage.sh b/test/shell/vgrename-usage.sh
index 59576ac..de1b933 100644
--- a/test/shell/vgrename-usage.sh
+++ b/test/shell/vgrename-usage.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 4
 pvcreate "$dev1" "$dev2"
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 4291dd4..8081b38 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -11,7 +11,7 @@
 
 # Test vgsplit operation, including different LV types
 
-. lib/test
+. lib/inittest
 
 COMM() {
 	LAST_TEST="$@"
diff --git a/test/shell/vgsplit-raid.sh b/test/shell/vgsplit-raid.sh
index 3174e88..a7c9687 100644
--- a/test/shell/vgsplit-raid.sh
+++ b/test/shell/vgsplit-raid.sh
@@ -11,7 +11,7 @@
 
 # Test vgsplit operation, including different LV types
 
-. lib/test
+. lib/inittest
 
 COMM() {
 	LAST_TEST="$@"
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 4373b20..42010fc 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. lib/test
+. lib/inittest
 
 aux extend_filter_LVMTEST
 aux prepare_pvs 3
diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
index 8fed1af..7b06132 100644
--- a/test/shell/vgsplit-thin.sh
+++ b/test/shell/vgsplit-thin.sh
@@ -11,7 +11,7 @@
 
 # Test vgsplit command options for validity
 
-. lib/test
+. lib/inittest
 
 aux have_thin 1 0 0 || skip
 
diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index 10167d7..fe999f9 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -11,7 +11,7 @@
 
 # Test vgsplit command options for validity
 
-. lib/test
+. lib/inittest
 
 aux prepare_devs 5
 
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
index b140558..046b3f5 100644
--- a/test/shell/zero-usage.sh
+++ b/test/shell/zero-usage.sh
@@ -11,7 +11,7 @@
 
 # Basic usage of zero target
 
-. lib/test
+. lib/inittest
 
 which md5sum || skip
 


