From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:32:02 -0400
Subject: master - tests: conversion only of exclusive lv
Message-ID: <201911011532.xA1FW2OD016971@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c935f8a327716292bb5454ae470143bfe7b1b3a9
Commit:        c935f8a327716292bb5454ae470143bfe7b1b3a9
Parent:        d1c5b3ae740481290de14d1ea178e571e689ff0e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 15:59:17 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 16:27:21 2019 +0100

tests: conversion only of exclusive lv

We can 'cache' only exclusively active LV in cluster.
---
 test/shell/cache-no-discard.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/cache-no-discard.sh b/test/shell/cache-no-discard.sh
index 3ab0594..4593622 100644
--- a/test/shell/cache-no-discard.sh
+++ b/test/shell/cache-no-discard.sh
@@ -35,7 +35,7 @@ pvcreate "$DM_DEV_DIR/$vg/$lv"
 vgcreate -s 128K $vg1 "$DM_DEV_DIR/$vg/$lv"
 
 # Create simple cache LV
-lvcreate -L2 -n $lv1 $vg1
+lvcreate -aey -L2 -n $lv1 $vg1
 lvcreate -H -L2 $vg1/$lv1
 
 #lvs -ao+kernel_discards $vg1


