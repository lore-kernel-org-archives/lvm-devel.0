From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:26 +0000 (UTC)
Subject: master - tests: use bigger metadata
Message-ID: <20140717142926.06E3960DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=27574d0e410c9b78a1bdc14dc6fd3c9ed2b6ca9f
Commit:        27574d0e410c9b78a1bdc14dc6fd3c9ed2b6ca9f
Parent:        53b787e519261008c4b1d96ea58243c9e2e06f25
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 17 16:27:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:27:39 2014 +0200

tests: use bigger metadata

Until resolved - use bigger then 4MB cache pool metadata.
---
 test/shell/pvmove-cache-segtypes.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index 1f5c6d9..9eaf186 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -142,7 +142,7 @@ lvremove -ff $vg
 #################################################
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 # RAID for cachepool
-lvcreate --type raid1 -m 1 -L 4M -n meta $vg "$dev1" "$dev2"
+lvcreate --type raid1 -m 1 -L 6M -n meta $vg "$dev1" "$dev2"
 lvcreate --type raid1 -m 1 -L 4M -n cachepool $vg "$dev1" "$dev2"
 lvconvert --yes --type cache-pool $vg/cachepool --poolmetadata $vg/meta
 # RAID for thin pool data LV


