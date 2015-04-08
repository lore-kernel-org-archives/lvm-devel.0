From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Apr 2015 21:20:36 +0000 (UTC)
Subject: master - tests: slowdown write on dev3 even more
Message-ID: <20150408212036.EDA246055A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=073643c9a2f0f92a2e3f236b0017db4bbc7c3a54
Commit:        073643c9a2f0f92a2e3f236b0017db4bbc7c3a54
Parent:        ebde60beab2d3421892a37780eacf7ed1459d8b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 8 23:16:08 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 23:19:38 2015 +0200

tests: slowdown write on dev3 even more

---
 test/shell/pvmove-abort.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 37837ba..3664deb 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -20,7 +20,7 @@ pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"
 
 # Slowdown read/writes
-aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
+aux delay_dev "$dev3" 0 400 $(get first_extent_sector "$dev3"):
 
 for mode in "--atomic" "" ;
 do


