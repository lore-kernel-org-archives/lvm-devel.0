From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:22 +0000 (GMT)
Subject: main - tests: update handling of thin-pool removal
Message-ID: <20210315101422.E6D623857C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=78406ef6174b20ba2ee3e6405b8ed39804990482
Commit:        78406ef6174b20ba2ee3e6405b8ed39804990482
Parent:        e5e957e3308a6a03503b6ded290dc975494204e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 11 10:25:41 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

tests: update handling of thin-pool removal

We shall no longer activate thin-pool, when
it's going away together with all thin volumes.
---
 test/shell/component-thin.sh | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/test/shell/component-thin.sh b/test/shell/component-thin.sh
index 3cf02f37d..ddadd0f8e 100644
--- a/test/shell/component-thin.sh
+++ b/test/shell/component-thin.sh
@@ -39,11 +39,5 @@ lvs -a
 # When component LVs are active, thin-pool cannot be actived
 not lvcreate -V20 $vg/pool
 
-
-# FIXME: ATM removal of thin volumes goes 1-by-1 and needs to activate thin-pool.
-# And thin-pool cannot be activate thus vgremove fails.
-# To fix this it would need to be able to remove volumes without activation.
-should vgremove -f $vg
-
-# -ff bypass activation failure
-vgremove -ff $vg
+# Rremoval of thin volumes should not need to activate thin-pool.
+vgremove -f $vg


