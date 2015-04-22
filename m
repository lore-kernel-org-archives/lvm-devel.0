From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:28 +0000 (UTC)
Subject: master - tests: use 800ms delay
Message-ID: <20150422092028.7270260DBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14c3f9603e5bcb83c91aff4ed162152dfa1a695e
Commit:        14c3f9603e5bcb83c91aff4ed162152dfa1a695e
Parent:        3f8da600795f65d7d8a692db35e7442899a40dc8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 22 09:01:03 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 09:09:26 2015 +0200

tests: use 800ms delay

Worked better with pvmove-abort-all so use here as well.
---
 test/shell/pvmove-abort.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 3417e77..72f6f96 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -20,7 +20,7 @@ pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"
 
 # Slowdown read/writes
-aux delay_dev "$dev3" 0 400 $(get first_extent_sector "$dev3"):
+aux delay_dev "$dev3" 0 800 $(get first_extent_sector "$dev3"):
 
 for mode in "--atomic" "" ;
 do


