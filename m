From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 May 2014 15:11:49 +0000 (UTC)
Subject: master - tests: detect same uuid on PV
Message-ID: <20140527151149.A3EB660E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a67774c1fa315e248504a51804cef9f9bc709b2e
Commit:        a67774c1fa315e248504a51804cef9f9bc709b2e
Parent:        9240aca369e210dddb3435433a3c9ac4fe35d357
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 27 16:51:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 27 17:09:05 2014 +0200

tests: detect same uuid on PV

Check we know how to handle same UUID
Test  currently does NOT work on lvmetad
(or it's unclear it even should - thus test error
is currently lowered to 'test warning')

TODO: replace lib/test with a better shell script name
---
 test/shell/lvmetad-same-uuid.sh |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-same-uuid.sh b/test/shell/lvmetad-same-uuid.sh
new file mode 100644
index 0000000..34cc8eb
--- /dev/null
+++ b/test/shell/lvmetad-same-uuid.sh
@@ -0,0 +1,27 @@
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
+. lib/test
+
+aux prepare_devs 3
+
+pvcreate "$dev1"
+UUID1=$(get pv_field "$dev1" uuid)
+pvcreate --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev2"
+pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev3"
+
+pvs -o+uuid |& tee out
+COUNT=$(should grep --count "Found duplicate" out)
+
+# FIXME  lvmetad is not able to serve properly this case
+should [ "$COUNT" -eq 2 ]
+
+pvs -o+uuid --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}"


