From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:48 +0200
Subject: [PATCH 02/14] Testsuit: Shell &&||
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <5b080c4d0409d304b4ce4403db9e52a4dba835b6.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Visually better align lines which are executed as a result of true
or false result of previous command.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/lvm-utils.sh      |    6 +++---
 test/t-000-basic.sh    |    4 ++--
 test/t-pvmove-basic.sh |    7 +++----
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/test/lvm-utils.sh b/test/lvm-utils.sh
index 39d52fd..6c00084 100644
--- a/test/lvm-utils.sh
+++ b/test/lvm-utils.sh
@@ -129,9 +129,9 @@ vg_validate_pvlv_counts_()
 
 	lvs -a -o+devices $local_vg
 
-	check_vg_field_ $local_vg pv_count $num_pvs &&
-	check_vg_field_ $local_vg lv_count $num_lvs &&
-	check_vg_field_ $local_vg snap_count $num_snaps
+	check_vg_field_ $local_vg pv_count $num_pvs && \
+	  check_vg_field_ $local_vg lv_count $num_lvs && \
+	  check_vg_field_ $local_vg snap_count $num_snaps
 }
 
 dmsetup_has_dm_devdir_support_()
diff --git a/test/t-000-basic.sh b/test/t-000-basic.sh
index c70a7f8..ed76a6f 100755
--- a/test/t-000-basic.sh
+++ b/test/t-000-basic.sh
@@ -20,9 +20,9 @@ lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual
 # ensure they are the same
 diff -u actual expected
 
-mknod $DM_DEV_DIR/null c 1 3 ||
+mknod $DM_DEV_DIR/null c 1 3 || \
   error "Can't create nodes on filesystem"
-echo >$DM_DEV_DIR/null || 
+echo >$DM_DEV_DIR/null || \
   error "Filesystem for tests does not allow using device nodes (check nodev)"
 
 # ensure we can create devices (uses dmsetup, etc)
diff --git a/test/t-pvmove-basic.sh b/test/t-pvmove-basic.sh
index cc2145b..44b533c 100755
--- a/test/t-pvmove-basic.sh
+++ b/test/t-pvmove-basic.sh
@@ -33,8 +33,7 @@ lv_is_on_() {
 }
 
 save_dev_sum_() {
-  mkfs.ext3 $1 > /dev/null &&
-  md5sum $1 > md5.$(basename $1)
+  mkfs.ext3 $1 > /dev/null && md5sum $1 > md5.$(basename $1)
 }
 
 check_dev_sum_() {
@@ -83,8 +82,8 @@ check_and_cleanup_lvs_() {
   lvs -a -o name $vg > out && ! grep ^pvmove out
   lvremove -ff $vg
 	if ! dmsetup table|not grep $vg; then
-		echo "ERROR: lvremove did leave some some mappings in DM behind!" &&
-		return 1
+		echo "ERROR: lvremove did leave some some mappings in DM behind!" && \
+			return 1
 	fi
 	:
 }
-- 
1.7.2


