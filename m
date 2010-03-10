From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 10 Mar 2010 14:24:18 -0500
Subject: [DRACUT PATCH] lvm_scan: use '--ignoremonitoring' rather than '--monitor n'
Message-ID: <1268249058-23510-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvchange and vgchange '--monitor n' will not prevent lvm from
attempting to dlopen the libdevmapper-event library.

dracut git commit 47ab3b6c5e introduced the use of '--monitor n' but
'--ignoremonitoring' is needed now that the libdevmapper-event library
isn't copied into the initramfs (ever since 0fae59d6eb3)

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 modules.d/90lvm/lvm_scan.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/modules.d/90lvm/lvm_scan.sh b/modules.d/90lvm/lvm_scan.sh
index 85cd78e..f4f7b4a 100755
--- a/modules.d/90lvm/lvm_scan.sh
+++ b/modules.d/90lvm/lvm_scan.sh
@@ -60,13 +60,13 @@ nopoll=$(
 if [ -n "$LVS" ] ; then
     info "Scanning devices $lvmdevs for LVM logical volumes $LVS"
     lvm lvscan --ignorelockingfailure 2>&1 | vinfo
-    lvm lvchange -ay --ignorelockingfailure $nopoll --monitor n $LVS 2>&1 | vinfo    
+    lvm lvchange -ay --ignorelockingfailure $nopoll --ignoremonitoring $LVS 2>&1 | vinfo
 fi
 
 if [ -z "$LVS" -o -n "$VGS" ]; then
     info "Scanning devices $lvmdevs for LVM volume groups $VGS"
     lvm vgscan --ignorelockingfailure 2>&1 | vinfo
-    lvm vgchange -ay --ignorelockingfailure $nopoll --monitor n $VGS 2>&1 | vinfo
+    lvm vgchange -ay --ignorelockingfailure $nopoll --ignoremonitoring $VGS 2>&1 | vinfo
 fi
 
 if [ "$lvmwritten" ]; then


