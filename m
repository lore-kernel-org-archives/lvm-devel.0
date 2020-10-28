From: David Teigland <teigland@sourceware.org>
Date: Wed, 28 Oct 2020 21:45:41 +0000 (GMT)
Subject: master - Revert "tests: revert lvm shell use in pvck-dump"
Message-ID: <20201028214541.89D15385EC58@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=125da10d47f4c1f72d3df99f2451c1eb031b9f3a
Commit:        125da10d47f4c1f72d3df99f2451c1eb031b9f3a
Parent:        05d23b2dd80919ebd2239cfd7f8e08d5de9ebace
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 28 16:45:04 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 28 16:45:04 2020 -0500

Revert "tests: revert lvm shell use in pvck-dump"

This reverts commit 05d23b2dd80919ebd2239cfd7f8e08d5de9ebace.

this required enabling editline in configure
---
 test/shell/pvck-dump.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index 80a01a214..c27fcc471 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -145,7 +145,7 @@ pvcreate --pvmetadatacopies 2 --metadatasize 32M "$dev1"
 
 vgcreate $SHARED -s 64K --metadatasize 32M $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
-for i in $(seq 1 500); do lvcreate -an -n lv$i -l1 $vg; done 
+for i in $(seq 1 500); do echo "lvcreate -an -n lv$i -l1 $vg"; done | lvm
 
 pvck --dump headers "$dev1" > h1
 


