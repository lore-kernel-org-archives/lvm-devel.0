From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 30 Nov 2009 17:35:05 -0500
Subject: [PATCH] dracut: do not allow lvm to effect metadata changes
Message-ID: <20091130223505.GC17549@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

mkinitrd produced an environment that was read-only.  As such lvm
commands that were executed by an initrd could not effect changes to LVM
VG metadata (because /var/lock/lvm was not writable).  Within an initrd
lvm commands always needed to use --ignorelockingfailure to allow
proper activation of the root LV.

However, Dracut provides a writable /var so it must take steps to
prevent lvm commands from making metadata changes (either directly
through lvm commands or indirectly with monitoring via dmeventd or
the lvm polldaemon that can fork from vgchange).

This patch provides the following changes:

* impose read-only locking for all lvm commands via the initramfs'
  lvm.conf (locking_type = 4)
  - the use of sed is placeholder "hack" until lvm2 provides a proper
    tool for changing lvm.conf
  - lvm_scan.sh should run lvm commands with --ignorelockingfailure to
    re-use lvm's existing initrd-specific logic; future lvm2 changes
    will split this flag out into various new command-line switches

* do not install dmeventd or its libraries into the initramfs
  - no monitoring should be started from within initramfs
  - NOTE: the same should apply to 90dmraid/install

* remove (incorrect) custom block device 'types'
  - the correct types would be: '[ "blkext", 1 , "cciss0", 16 ]'
  - but lvm2 (>= 2.02.52) already properly supports both 'blkext' and
    'cciss' (including cciss0 -> cciss7)

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
diff --git a/modules.d/90lvm/install b/modules.d/90lvm/install
index 56e2eb0..2d622f5 100755
--- a/modules.d/90lvm/install
+++ b/modules.d/90lvm/install
@@ -1,23 +1,17 @@
 #!/bin/bash
 inst lvm
-inst dmeventd
-
-if ldd $(which lvm) | grep -q lib64; then
-    LIBDIR="/lib64"
-else
-    LIBDIR="/lib"
-fi
 
 inst_rules "$moddir/64-lvm.rules" 64-lvm.rules
 
 if [[ $hostonly ]] || [[ $lvmconf = "yes" ]]; then 
-    [ -f /etc/lvm/lvm.conf ] && inst /etc/lvm/lvm.conf
+    if [ -f /etc/lvm/lvm.conf ]; then
+	inst /etc/lvm/lvm.conf
+	# FIXME: near-term hack to establish read-only locking;
+	# use command-line lvm.conf editor once it is available
+	sed -i -e 's/\(^[[:space:]]*\)locking_type[[:space:]]*=[[:space:]]*[[:digit:]]/\1locking_type = 4/' ${initdir}/etc/lvm/lvm.conf
+    fi
 fi
 
-for i in $(ls /$LIBDIR/libdevmapper-event*.so 2>/dev/null); do 
-    dracut_install $i
-done
-
 inst_rules 10-dm.rules 13-dm-disk.rules 95-dm-notify.rules 11-dm-lvm.rules
 
 inst "$moddir/lvm_scan.sh" /sbin/lvm_scan
diff --git a/modules.d/90lvm/lvm_scan.sh b/modules.d/90lvm/lvm_scan.sh
index 73ba845..3bf858a 100755
--- a/modules.d/90lvm/lvm_scan.sh
+++ b/modules.d/90lvm/lvm_scan.sh
@@ -23,14 +23,17 @@ if [ ! -e /etc/lvm/lvm.conf ]; then
 	    printf '"a|^/dev/%s$|", ' $dev;
 	done;
 	echo '"r/.*/" ]';
-	echo 'types = [ "blkext", 1024 , "cciss0", 1024 ]'
 	echo '}';	  
+	# establish read-only locking
+	echo 'global {';
+	echo '    locking_type = 4';
+	echo '}';
     } > /etc/lvm/lvm.conf
     lvmwritten=1
 fi
 info "Scanning devices $lvmdevs for LVM volume groups $VGS"
-lvm vgscan 2>&1 | vinfo
-lvm vgchange -ay --monitor n $VGS 2>&1 | vinfo
+lvm vgscan --ignorelockingfailure 2>&1 | vinfo
+lvm vgchange -ay --ignorelockingfailure --monitor n $VGS 2>&1 | vinfo
 if [ "$lvmwritten" ]; then
     rm -f /etc/lvm/lvm.conf
     ln -s /sbin/lvm-cleanup /pre-pivot/30-lvm-cleanup.sh 2>/dev/null


