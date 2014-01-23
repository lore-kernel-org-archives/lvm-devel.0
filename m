From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jan 2014 13:23:49 +0000 (UTC)
Subject: master - tests: thin external origin resize
Message-ID: <20140123132349.0BB916062C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1df1f3a81a0ff24ba2e25ed6680fcb653655dee
Commit:        c1df1f3a81a0ff24ba2e25ed6680fcb653655dee
Parent:        f8b20fb8e8e54561321b030fae7249ac2c2ac950
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 23 14:17:00 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 23 14:22:34 2014 +0100

tests: thin external origin resize

---
 test/shell/lvresize-thin-external-origin.sh |   42 +++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
new file mode 100644
index 0000000..d9739c0
--- /dev/null
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -0,0 +1,42 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test resize of thin volume with external origin
+. lib/test
+
+aux have_thin 1 2 0 || skip
+
+# Pretend we miss the external_origin_extend feature
+aux lvmconf "global/thin_disabled_features = [ \"external_origin_extend\" ]"
+
+aux prepare_pvs 2
+
+vgcreate -s 1M $vg $(cat DEVICES)
+
+lvcreate -L10 -n $lv1 $vg
+
+# Prepare thin pool
+lvcreate -L20 -T $vg/pool
+
+# Convert $lv1 into thin LV with external origin
+lvconvert -T $vg/$lv1 --thinpool $vg/pool --originname ext
+
+lvs -a $vg
+
+# Bigger size is not supported without feature external_origin_extend
+not lvresize -L+10 $vg/$lv1
+
+# But reduction works
+lvresize -L-5 -f $vg/$lv1
+not lvresize -L+15 -y $vg/$lv1
+# We may size again back up to the size of external origin
+# TODO: hmm do we really want this???
+lvresize -L+5 -f $vg/$lv1


