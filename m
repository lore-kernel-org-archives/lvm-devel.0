From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 27 Jun 2019 05:14:57 -0400
Subject: master - test: Remove now useless clvmd test
Message-ID: <201906270914.x5R9Evcw012716@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba9d152aa5552f2b6d9ea3acf5ae644dc4dd1596
Commit:        ba9d152aa5552f2b6d9ea3acf5ae644dc4dd1596
Parent:        09f29570f2dac1a84f5ee24107df6461194b269a
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jun 27 11:14:00 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jun 27 11:14:00 2019 +0200

test: Remove now useless clvmd test

---
 test/shell/clvmd-restart.sh |   73 -------------------------------------------
 1 files changed, 0 insertions(+), 73 deletions(-)

diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
deleted file mode 100644
index 7e3257a..0000000
--- a/test/shell/clvmd-restart.sh
+++ /dev/null
@@ -1,73 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# set before test's clvmd is started, so it's passed in environ
-export LVM_CLVMD_BINARY=clvmd
-export LVM_BINARY=lvm
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_CLVMD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-# only clvmd based test, skip otherwise
-read -r LOCAL_CLVMD < LOCAL_CLVMD
-
-# TODO read from build, for now hardcoded
-CLVMD_SOCKET="/var/run/lvm/clvmd.sock"
-
-restart_clvmd_() {
-	"$LVM_CLVMD_BINARY" -S
-	ls -la "$CLVMD_SOCKET" || true
-
-	for i in $(seq 1 20) ; do
-		test -S "$CLVMD_SOCKET" && break
-		sleep .1
-	done
-	# restarted clvmd has the same PID (no fork, only execvp)
-	NEW_LOCAL_CLVMD=$(pgrep clvmd)
-	test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
-}
-
-aux prepare_vg
-
-lvcreate -an --zero n -n $lv1 -l1 $vg
-lvcreate -an --zero n -n $lv2 -l1 $vg
-lvcreate -l1 $vg
-
-lvchange -aey $vg/$lv1
-lvchange -aey $vg/$lv2
-
-restart_clvmd_
-
-# try restart once more
-restart_clvmd_
-
-# FIXME: Hmm - how could we test exclusivity is preserved in singlenode ?
-lvchange -an $vg/$lv1
-lvchange -aey $vg/$lv1
-lvcreate -s -l3 -n snap $vg/$lv1
-
-"$LVM_CLVMD_BINARY" -R
-
-vgchange -an $vg
-
-# Test what happens after 'reboot'
-kill "$LOCAL_CLVMD"
-while test -e "$CLVMD_PIDFILE"; do echo -n .; sleep .1; done # wait for the pid removal
-aux prepare_clvmd
-
-vgchange -ay $vg
-lvremove -f $vg/snap
-
-vgremove -ff $vg


