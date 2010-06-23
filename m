From: Milan Broz <mbroz@redhat.com>
Date: Wed, 23 Jun 2010 13:30:07 +0200
Subject: [PATCH] Fix clvmd init script status
Message-ID: <1277292607-29658-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

- s/Active clustred VG/clustered VG/ (only LV can be active)

- print only active LVs (not all) in status command
(In the lvdisplay form /dev/vg/lv.)

For now, still use awk (already used in clustered_vgs).

https://bugzilla.redhat.com/show_bug.cgi?id=598495
---
 scripts/clvmd_init_red_hat.in |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/scripts/clvmd_init_red_hat.in b/scripts/clvmd_init_red_hat.in
index 1a03984..da09a34 100644
--- a/scripts/clvmd_init_red_hat.in
+++ b/scripts/clvmd_init_red_hat.in
@@ -25,7 +25,7 @@ sbindir=@sbindir@
 lvm_vgchange=${sbindir}/vgchange
 lvm_vgdisplay=${sbindir}/vgdisplay
 lvm_vgscan=${sbindir}/vgscan
-lvm_lvs=${sbindir}/lvs
+lvm_lvdisplay=${sbindir}/lvdisplay
 
 CLVMDOPTS="-T30"
 
@@ -47,9 +47,10 @@ clustered_vgs() {
 		awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'
 }
 
-clustered_lvs() {
+clustered_active_lvs() {
 	for i in $(clustered_vgs); do
-		${lvm_lvs} -o lv_name --noheadings $i
+		${lvm_lvdisplay} $i 2>/dev/null | \
+		awk 'BEGIN {RS="LV Name"} {if (/[^N^O^T] available/) print $1;}'
 	done
 }
 
@@ -197,8 +198,8 @@ case "$1" in
 	rtrn=$?
 	if [ $rtrn = 0 ]; then
 		cvgs="$(clustered_vgs)"
-		echo Active clustered Volume Groups: ${cvgs:-"(none)"}
-		clvs="$(clustered_lvs)"
+		echo Clustered Volume Groups: ${cvgs:-"(none)"}
+		clvs="$(clustered_active_lvs)"
 		echo Active clustered Logical Volumes: ${clvs:-"(none)"}
 	fi
 	;;
-- 
1.7.1


