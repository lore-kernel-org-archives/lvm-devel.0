From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:13 +0000 (UTC)
Subject: dev-mornfall-activate - vgimportclone: override global_filter in lvm.conf
Message-ID: <20130604192813.854846125D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05bf4b8cc3e3d15e79c9964e496dbe396beacb3c
Commit:        05bf4b8cc3e3d15e79c9964e496dbe396beacb3c
Parent:        c5f7d401e5e558ea7dffaa326a27dd432241e639
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Apr 28 22:38:22 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:47:17 2013 +0200

vgimportclone: override global_filter in lvm.conf

The global filter in system's lvm.conf may conflict with the custom filter we
set up in vgimportclone (they can easily fail to intersect). Since we explicitly
avoid talking to lvmetad in vgimportclone, it is safe and reasonable to do so.
---
 WHATS_NEW                |    1 +
 scripts/vgimportclone.sh |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7589f12..56868b7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Override system's global_filter settings for vgimportclone.
   Detect maximum usable size for snapshot for lvresize.
   Creation of snapshot takes at most 100% origin coverage.
   Add cow_max_extents() to calc extents for 100% origin coverage.
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 520ca02..d6ad75d 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -250,6 +250,7 @@ LVMCONF=${TMP_LVM_SYSTEM_DIR}/lvm.conf
      /^[ \t]*scan[ \t]*=/{print "scan = [ \"" DEV "\" ]";next} \
      /^[ \t]*cache[ \t]*=/{print "cache = \"" CACHE "\"";next} \
      /^[ \t]*use_lvmetad[ \t]*=/{print "use_lvmetad = 0";next} \
+     /^[ \t]*global_filter[ \t]*=/{print "global_filter = [ \"a|.*|\" ]";next} \
      /^[ \t]*cache_dir[ \t]*=/{print "cache_dir = \"" CACHE_DIR "\"";next} \
      {print $0}' > ${LVMCONF}
 


