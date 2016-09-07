From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  7 Sep 2016 01:35:13 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160907013513.6BA6E60DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d2b1ff5c4cfbeec36b4ab93dc08e87a252b7fed
Commit:        3d2b1ff5c4cfbeec36b4ab93dc08e87a252b7fed
Parent:        a6bcdbe13c25af3cf4bfd0849342fff5ffd75700
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 7 02:25:51 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 7 02:25:51 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    8 ++++++--
 WHATS_NEW_DM |    5 +++--
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 58f1a65..244677c 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.165(2)-git (2016-08-15)
+2.02.165(2)-git (2016-09-07)
diff --git a/VERSION_DM b/VERSION_DM
index 7cfcd9a..a993372 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.134-git (2016-08-15)
+1.02.134-git (2016-09-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index 4cee0e4..d80b1ff 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,10 @@
-Version 2.02.165 - 
-===================================
+Version 2.02.165 - 7th September 2016
+=====================================
+  Add lvmraid(7) man page.
   Use udev db to check for mpath components before running pvscan for lvmetad.
   Use lsblk -s and lsblk -O in lvmdump only if these options are supported.
   Fix number of stripes shown in lvcreate raid10 message when too many.
+  Change lvmdbusd to use new lvm shell facilities.
   Do not monitor cache-pool metadata when LV is just being cleared.
   Add allocation/cache_pool_max_chunks to prevent misuse of cache target.
   Give error not segfault in lvconvert --splitmirrors when PV lies outside LV.
@@ -13,6 +15,8 @@ Version 2.02.165 -
   Don't allow lvconvert --repair on raid0 devices or attempt to monitor them.
   No longer adjust incorrect number of raid stripes supplied to lvcreate.
   Move lcm and gcd to lib/misc.
+  Fix vgsplit of external origins. (2.02.162)
+  Prohibit creation of RAID LVs unless VG extent size is at least the page size.
   Suppress some unnecessary --stripesize parameter warnings.
   Fix 'pvmove -n name ...' to prohibit collocation of RAID SubLVs
 
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7bbfd88..eaead89 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
-Version 1.02.134 - 
-===================================
+Version 1.02.134 - 7th September 2016
+=====================================
+  Improve explanation of udev fallback in libdevmapper.h.
 
 Version 1.02.133 - 10th August 2016
 ===================================


