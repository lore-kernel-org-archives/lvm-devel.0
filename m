From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 26 May 2013 17:11:52 +0000 (UTC)
Subject: dev-mornfall-nix - vgimportclone: Override global_filter in the local lvm.conf.
Message-ID: <20130526171152.AE8AE60F9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a50d2baf0bb2cda25002d9d627ede030296b83ef
Commit:        a50d2baf0bb2cda25002d9d627ede030296b83ef
Parent:        8cbacd2474b288a581274dba9b623ec2e9ac9d28
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Apr 28 22:38:22 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun May 26 18:54:45 2013 +0200

vgimportclone: Override global_filter in the local lvm.conf.

The global filter in system's lvm.conf may conflict with the custom filter we
set up in vgimportclone (they can easily fail to intersect). Since we explicitly
avoid talking to lvmetad in vgimportclone, it is safe and reasonable to do so.
---
 scripts/vgimportclone.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

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
 


