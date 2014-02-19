From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Feb 2014 22:36:34 +0000 (UTC)
Subject: master - tests: add small test for clustered conversion of mirror
Message-ID: <20140219223634.9F6CC60DB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e83682ccf1862289ed2f3bcbe03cfa1c190e1e0
Commit:        5e83682ccf1862289ed2f3bcbe03cfa1c190e1e0
Parent:        b391ae88e5ed3720a8b5a87312e0cd907a94fcc2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 19 23:30:49 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 19 23:34:07 2014 +0100

tests: add small test for clustered conversion of mirror

Test currently fails with make check_cluster - so uses 'should'

CLVMD[4f435880]: Feb 19 23:27:36 Send local reply
format_text/archiver.c:230   WARNING: This metadata update is NOT backed up
metadata/mirror.c:1105   Failed to initialize log device
metadata/mirror.c:1145         <backtrace>
lvconvert.c:1547         <backtrace>
lvconvert.c:3084         <backtrace>
---
 test/shell/lvconvert-mirror-updown.sh |   36 +++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
new file mode 100644
index 0000000..3b30738
--- /dev/null
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -0,0 +1,36 @@
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
+# Demonstrate problem when upconverting and cutting leg in clvmd
+
+. lib/test
+
+aux prepare_pvs 3
+
+vgcreate -s 64k $vg $(cat DEVICES)
+
+lvcreate -aey -l10 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2"
+
+# Slow down device so we are able to start next conversion in parallel
+aux delay_dev "$dev3" 0 200
+
+lvconvert -m+1 -b $vg/$lv1 "$dev3"
+
+# To fix - wait helps here....
+#lvconvert $vg/$lv1
+
+lvs -a $vg
+#
+# It fails so use 'should' and -vvvv for now
+#
+should lvconvert -vvvv -m-1 $vg/$lv1 "$dev2"
+
+vgremove -f $vg


