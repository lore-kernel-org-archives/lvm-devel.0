From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Jul 2015 11:10:46 +0000 (UTC)
Subject: master - thin: fix warning for overprovisioning
Message-ID: <20150715111046.A2EB0609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a33d5714341caf281f8e519b4b6c875d6eba292
Commit:        4a33d5714341caf281f8e519b4b6c875d6eba292
Parent:        34a410994674f450564d6f221ff5ef0b16d37280
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 13 11:08:49 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 15 13:10:21 2015 +0200

thin: fix warning for overprovisioning

When lvm.conf is properly configure for auto resize of overprovisioned
thin-pool volume, avoid showing any warning (2.02.124).
---
 WHATS_NEW                                     |    1 +
 lib/metadata/thin_manip.c                     |    2 ++
 test/shell/lvextend-thin-metadata-dmeventd.sh |    3 ++-
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4fd027c..3a8cd9e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Fix detection of thin-pool overprovisioning (2.02.124).
   Fix lvmpolld segfaults on 32 bit architectures.
   Fix ignored --startstopservices option if running lvmconf with systemd.
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 181c72e..d0a5c55 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -303,6 +303,8 @@ int pool_check_overprovisioning(const struct logical_volume *lv)
 		/* There is some free space in VG, but it is not configured
 		 * for growing - threshold is 100% or percent is 0% */
 		sz = poolsum;
+	else
+		sz = ~0; /* No warning */
 
 	if (sz != ~0) {
 		log_warn("WARNING: Sum of all thin volume sizes (%s) exceeds the "
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 72cdb81..6897072 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -61,7 +61,8 @@ aux prepare_pvs 3 256
 vgcreate -s 1M $vg $(cat DEVICES)
 
 # Testing dmeventd autoresize
-lvcreate -L200M -V1G -n thin -T $vg/pool
+lvcreate -L200M -V500M -n thin -T $vg/pool 2>&1 | tee out
+not grep "WARNING: Sum" out
 lvcreate -L2M -n $lv1 $vg
 lvchange -an $vg/thin $vg/pool
 


