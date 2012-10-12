From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 10:22:21 +0000 (UTC)
Subject: master - thin: prohibit lvcreate --thinpool with mirrors
Message-ID: <20121012102221.EA1CDA2BCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3058f662cf08bee36e7ff465e6f222cd8ced0ad2
Commit:        3058f662cf08bee36e7ff465e6f222cd8ced0ad2
Parent:        be291e106458a0ae1024bd517a37d471c032c505
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 12:18:06 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 12:21:45 2012 +0200

thin: prohibit lvcreate --thinpool with mirrors

Disable --thinpool to be used with mirror on lvcreate.
---
 WHATS_NEW                   |    1 +
 test/shell/lvcreate-thin.sh |    8 ++++++--
 tools/lvcreate.c            |    5 +++--
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 047e2ed..211d1bb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Prohibit usage of lvcreate --thinpool with --mirrors.
   Fix lvm2api origin reporting for thin snapshot volume.
   Add configure --enable-python_bindings for liblvm2app to new python subdir.
   Add implementation of lvm2api function lvm_percent_to_float.
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 6f60976..8ac5468 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -174,14 +174,18 @@ not lvcreate -L4M --chunksize 2G -T $vg/pool1
 lvcreate -L4M -V2G --name lv1 -T $vg/pool1
 # Origin name is not accepted
 not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
-vgremove -ff $vg
 
+# Check we cannot create mirror and thin or thinpool together
+not lvcreate -T mirpool -L4M --alloc anywhere -m1 $vg
+not lvcreate --thinpool mirpool -L4M --alloc anywhere -m1 $vg
+
+vgremove -ff $vg
 
 # Test --poolmetadatasize range
 # allocating large devices for testing
 aux teardown_devs
 aux prepare_pvs 10 16500
-vgcreate $clustered $vg -s 64K $(cat DEVICES)
+vgcreate $vg -s 64K $(cat DEVICES)
 
 lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
 grep "WARNING: Minimum" out
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7d01685..53c4940 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -694,8 +694,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	 * Check selected options are compatible and determine segtype
 	 */
 // FIXME -m0 implies *striped*
-	if (arg_count(cmd, thin_ARG) && arg_count(cmd,mirrors_ARG)) {
-		log_error("--thin and --mirrors are incompatible.");
+	if ((arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG)) &&
+	    arg_count(cmd,mirrors_ARG)) {
+		log_error("--thin,--thinpool  and --mirrors are incompatible.");
 		return 0;
 	}
 


