From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:26:16 -0400
Subject: stable-2.02 - tests: conversion only of exclusive lv
Message-ID: <201911011526.xA1FQGEa016347@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=010062cf03327340053bd1e96613bda9240e3464
Commit:        010062cf03327340053bd1e96613bda9240e3464
Parent:        df00a62fd0a4a4f8a57ac34a80b37ddfb6e98d74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 15:59:17 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 15:59:17 2019 +0100

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


