From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 Jan 2015 15:41:44 +0000 (UTC)
Subject: master - scripts: clvmd: replace awk functionality with LVM's selection
Message-ID: <20150109154144.3F99660D25@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a77b6f43c7c9a90210bb90be55c4060e612106d
Commit:        6a77b6f43c7c9a90210bb90be55c4060e612106d
Parent:        fb7e2ff49368e547d597baf263e8cb7cca8b63fb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 9 16:34:16 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 9 16:41:07 2015 +0100

scripts: clvmd: replace awk functionality with LVM's selection

No need to use awk now to get appropriate VGs/LVs, use LVM's
own --select - it's quicker, it removes a need for external
dependency on awk and it's also more readable.
---
 WHATS_NEW                                     |    1 +
 scripts/clvmd_init_red_hat.in                 |   13 ++++---------
 scripts/lvm2_cluster_activation_red_hat.sh.in |   10 +---------
 3 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 893c382..242c17d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Use LVM's own selection instead of awk expressions in clvmd startup scripts.
   Do not filter out snapshot origin LVs as unusable devices for an LVM stack.
   Fix incorrect rimage names when converting from mirror to raid1 LV (2.02.112).
   Avoid excessive re-reading of metadata and related error messages in pvremove.
diff --git a/scripts/clvmd_init_red_hat.in b/scripts/clvmd_init_red_hat.in
index 8c46c06..d7f3392 100644
--- a/scripts/clvmd_init_red_hat.in
+++ b/scripts/clvmd_init_red_hat.in
@@ -24,9 +24,9 @@ exec_prefix=@exec_prefix@
 sbindir=@sbindir@
 
 lvm_vgchange=${sbindir}/vgchange
-lvm_vgdisplay=${sbindir}/vgdisplay
+lvm_vgs=${sbindir}/vgs
 lvm_vgscan=${sbindir}/vgscan
-lvm_lvdisplay=${sbindir}/lvdisplay
+lvm_lvs=${sbindir}/lvs
 
 CLVMDOPTS="-T30"
 
@@ -42,17 +42,12 @@ CLVMDOPTS="-T30"
 
 LOCK_FILE="/var/lock/subsys/$DAEMON"
 
-# NOTE: replace this with vgs, once display filter per attr is implemented.
 clustered_vgs() {
-	${lvm_vgdisplay} 2>/dev/null | \
-		awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'
+	${lvm_vgs} --noheadings -o vg_name -S 'vg_clustered=1' 2>/dev/null
 }
 
 clustered_active_lvs() {
-	for i in $(clustered_vgs); do
-		${lvm_lvdisplay} $i 2>/dev/null | \
-		awk 'BEGIN {RS="LV Name"} {if (/[^N^O^T] available/) print $1;}'
-	done
+	${lvm_lvs} --noheadings -o lv_name -S 'vg_clustered=1 && lv_active!=""' 2>/dev/null
 }
 
 rh_status() {
diff --git a/scripts/lvm2_cluster_activation_red_hat.sh.in b/scripts/lvm2_cluster_activation_red_hat.sh.in
index 0d4676c..abea026 100644
--- a/scripts/lvm2_cluster_activation_red_hat.sh.in
+++ b/scripts/lvm2_cluster_activation_red_hat.sh.in
@@ -7,16 +7,8 @@ lvm_vgscan=${sbindir}/vgscan
 lvm_vgs=${sbindir}/vgs
 lvm_lvm=${sbindir}/lvm
 
-parse_clustered_vgs() {
-	while read -r name attrs;
-	do
-		test "${attrs:5:1}" == 'c' && echo -n "$name "
-	done
-}
-
-# NOTE: replace this with vgs, once display filter per attr is implemented.
 clustered_vgs() {
-	${lvm_vgs} -o vg_name,vg_attr --noheadings | parse_clustered_vgs
+	${lvm_vgs} --noheadings -o vg_name -S 'vg_clustered=1' 2>/dev/null
 }
 
 activate() {


