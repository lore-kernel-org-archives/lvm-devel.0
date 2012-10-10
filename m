From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Oct 2012 19:23:09 +0000 (UTC)
Subject: master - test: thin support for non power of 2 chunk size
Message-ID: <20121010192309.AEFC5AB3C8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9db5217a3111f72298de31a6b94d33fff39401a3
Commit:        9db5217a3111f72298de31a6b94d33fff39401a3
Parent:        876514eb34d3b67cb1063ea2feca49a76be65229
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 10 16:37:55 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 10 21:22:12 2012 +0200

test: thin support for non power of 2 chunk size

---
 test/shell/lvcreate-thin-power2.sh |   39 ++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
new file mode 100644
index 0000000..e1c793c
--- /dev/null
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -0,0 +1,39 @@
+#!/bin/sh
+
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+#
+# test support for non-power-of-2 thin chunk size
+#
+
+. lib/test
+
+#
+# Main
+#
+aux have_thin 1 2 0 || skip
+
+aux prepare_pvs 2 64
+
+vgcreate $vg -s 64K $(cat DEVICES)
+
+# create non-power-of-2 pool
+lvcreate -l100 -c 192 -T $vg/pool
+
+check lv_field $vg/pool discards "ignore"
+
+# check we cannot change discards settings
+not lvchange --discard passdown $vg/pool
+not lvchange --discard nopassdown $vg/pool
+
+# must be multiple of 64KB
+not lvcreate -l100 -c 168 -T $vg/pool1
+
+vgremove -ff $vg


