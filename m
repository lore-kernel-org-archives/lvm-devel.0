From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 30 Mar 2014 21:46:06 +0000 (UTC)
Subject: master - tests: more vgexport tests
Message-ID: <20140330214606.61FF6602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c8f0c9800e658c14d57f1726055876dab869d08
Commit:        2c8f0c9800e658c14d57f1726055876dab869d08
Parent:        cc82dc7b23902c900ac59c35566bd63d65902155
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 30 22:45:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 30 23:45:00 2014 +0200

tests: more vgexport tests

cover more options
---
 test/shell/vgimportclone.sh |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 923638e..29c172e 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2010-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2014 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -17,9 +17,27 @@ vgcreate --metadatasize 128k $vg1 "$dev1"
 lvcreate -l100%FREE -n $lv1 $vg1
 
 # Test plain vgexport vgimport tools
+
+# Argument is needed
+invalid vgexport
+invalid vgimport
+# Cannot combine -a and VG name
+invalid vgexport -a $vg
+invalid vgimport -a $vg1
+# Cannot export unknonw VG
+fail vgexport ${vg1}-non
+fail vgimport ${vg1}-non
+# Cannot export VG with active volumes
+fail vgexport $vg1
+
 vgchange -an $vg1
 vgexport $vg1
+# Already exported
+fail vgexport $vg1
+
 vgimport $vg1
+# Already imported
+fail vgimport $vg1
 vgchange -ay $vg1
 
 # Clone the LUN


