From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Dec 2014 13:02:11 +0000 (UTC)
Subject: master - vgimportclone: replace awk with dumpconfig to generate temporary lvm.conf for vgimportclone
Message-ID: <20141210130212.0787060C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00b36ef06acb15c82d7c9b37872753f02c638316
Commit:        00b36ef06acb15c82d7c9b37872753f02c638316
Parent:        5378a1a63e8a8d89cca9460051d473b7547404f9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 10 13:25:23 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 10 13:59:38 2014 +0100

vgimportclone: replace awk with dumpconfig to generate temporary lvm.conf for vgimportclone

With current dumpconfig, we can generate lvm.conf easily - we can merge
current lvm.conf with the config given on cmd line:
  lvm dumpconfig --mergedconfig --config "..."

This is a bit simpler than using awk and it also avoids problems when some of
the configuration is missing in existing lvm.conf file and hardcoded defaults
are used instead. The dumpconfig handles this transparently.
---
 WHATS_NEW                |    1 +
 scripts/vgimportclone.sh |   22 +++++++++++-----------
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9201f36..72d3b6a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Fix vgimportclone to properly override config if it is missing in lvm.conf.
   Fix automatic use of configure --enable-udev-systemd-background-jobs.
   Correctly rename active split LV with -splitmirrors for raid1.
   Add report/compact_output to lvm.conf to enable/disable compact report output.
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 7087557..bfff131 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -242,17 +242,17 @@ export FILTER="filter=[ ${FILTER} \"r|.*|\" ]"
 
 LVMCONF=${TMP_LVM_SYSTEM_DIR}/lvm.conf
 
-# FIXME convert to cmdline override
-"$LVM" dumpconfig ${LVM_OPTS} | \
-"$AWK" -v DEV=${TMP_LVM_SYSTEM_DIR} -v CACHE=${TMP_LVM_SYSTEM_DIR}/.cache \
-    -v CACHE_DIR=${TMP_LVM_SYSTEM_DIR}/cache \
-    '/^[ \t]*filter[ \t]*=/{print ENVIRON["FILTER"];next} \
-     /^[ \t]*scan[ \t]*=/{print "scan = [ \"" DEV "\" ]";next} \
-     /^[ \t]*cache[ \t]*=/{print "cache = \"" CACHE "\"";next} \
-     /^[ \t]*use_lvmetad[ \t]*=/{print "use_lvmetad = 0";next} \
-     /^[ \t]*global_filter[ \t]*=/{print "global_filter = [ \"a|.*|\" ]";next} \
-     /^[ \t]*cache_dir[ \t]*=/{print "cache_dir = \"" CACHE_DIR "\"";next} \
-     {print $0}' > ${LVMCONF}
+CMD_CONFIG_LINE="devices { \
+                   scan = [ \"${TMP_LVM_SYSTEM_DIR}\" ] \
+                   cache_dir = \"$TMP_LVM_SYSTEM_DIR}/cache\"
+                   global_filter = [ \"a|.*|\" ] \
+                   ${FILTER}
+                 } \
+                 global { \
+                   use_lvmetad = 0 \
+                 }"
+
+$LVM dumpconfig ${LVM_OPTS} --file ${LVMCONF} --mergedconfig --config "${CMD_CONFIG_LINE}"
 
 checkvalue $? "Failed to generate ${LVMCONF}"
 # Only keep TMP_LVM_SYSTEM_DIR if it contains something worth keeping


