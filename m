From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 May 2019 09:17:37 -0400
Subject: stable-2.02 - tests: check accepting out-of-range creation_time
Message-ID: <201905101317.x4ADHbe8032722@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5a5792b30c74b9b4d839b5a33c466c2ac012d0c
Commit:        d5a5792b30c74b9b4d839b5a33c466c2ac012d0c
Parent:        a397b69ce33d811aba7d64d54b5c8e0efb86fd15
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 10 15:00:21 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 10 15:07:25 2019 +0200

tests: check accepting out-of-range creation_time

---
 test/shell/creation-time.sh |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/test/shell/creation-time.sh b/test/shell/creation-time.sh
new file mode 100644
index 0000000..2a4a387
--- /dev/null
+++ b/test/shell/creation-time.sh
@@ -0,0 +1,40 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2019 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Check we can read metadata with out-of-range creation time
+
+# Due to a bug in 32-bit version lvm2 <2.02.169  produced metadata
+# contained invalid number for creation_time
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_vg 1
+
+lvcreate -an -L1 -n $lv1 $vg
+
+vgcfgbackup -f back $vg
+
+sed -e 's/creation_time = \(.*\)$/creation_time = 12029933779523993599/g' back >backnew
+
+vgcfgrestore -f backnew $vg  |& tee err
+
+# Check the time was spotted
+grep Invalid err
+
+vgcfgbackup -f back $vg |& tee err
+
+# Check the time is not a problem anymore
+not grep Invalid err
+
+vgremove -ff $vg


