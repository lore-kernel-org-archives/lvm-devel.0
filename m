From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:30 +0000 (UTC)
Subject: master - lvconvert/lvcreate: raise maximum number of raid images
Message-ID: <20170224063230.499EC60AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64a2fad5d6c65e81269251408dff10854f0ace7e
Commit:        64a2fad5d6c65e81269251408dff10854f0ace7e
Parent:        34caf8317243b3b30e6fc858b4440ebf3ffb8810
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 04:41:46 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert/lvcreate: raise maximum number of raid images

Because of contraints in renaming shifted rimage/rmeta LV names
the current RaidLV limit is a maximum of 10 SubLV pairs.

With the previous introduction of reshaping infratructure that
constriant got removed.

Kernel supports 253 since dm-raid target 1.9.0, older kernels 64.

Raise the maximum number of RaidLV rimage/rmeta pairs to 64.
If we want to raise past 64, we have to introdce a check for
the kernel supporting it in lvcreate/lvconvert.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/config/defaults.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index db78f0c..5554c9c 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -71,8 +71,8 @@
  * FIXME: Increase these to 64 and further to the MD maximum
  *	  once the SubLVs split and name shift got enhanced
  */
-#define DEFAULT_RAID1_MAX_IMAGES 10
-#define DEFAULT_RAID_MAX_IMAGES 10
+#define DEFAULT_RAID1_MAX_IMAGES 64
+#define DEFAULT_RAID_MAX_IMAGES 64
 #define DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES 0 /* Don't stripe across all devices if not -i/--stripes given */
 
 #define DEFAULT_RAID_FAULT_POLICY "warn"


