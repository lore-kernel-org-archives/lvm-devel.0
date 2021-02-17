From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:45 +0000 (GMT)
Subject: main - tests: lvconvert vdo profile support
Message-ID: <20210217105445.D426A3854819@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fbaf5a32bb3465d121f60db5a77df2e86b0bf49b
Commit:        fbaf5a32bb3465d121f60db5a77df2e86b0bf49b
Parent:        9c0ce4daa2accbfeec2a09729f73ef7a5876c658
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 16 21:30:40 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:53:19 2021 +0100

tests: lvconvert vdo profile support

---
 test/shell/profiles-vdo.sh | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/shell/profiles-vdo.sh b/test/shell/profiles-vdo.sh
index c870315a0..7b3c343f3 100644
--- a/test/shell/profiles-vdo.sh
+++ b/test/shell/profiles-vdo.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018-2021 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-# Exercise obtaining cache parameter from various sources
+# Exercise obtaining vdo parameters from various sources
 # Either commmand line or metadata profile or implicit default...
 
 
@@ -47,4 +47,8 @@ lvdisplay -m $vg/vdopool | tee out
 grep "Compression.*no" out
 lvremove -f $vg
 
+lvcreate -L4G --name vdopool $vg
+lvconvert --yes --type vdo-pool --metadataprofile "$PFILE" $vg/vdopool
+check lv_field $vg/vdopool vdo_compression ""
+
 vgremove -ff $vg


