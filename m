From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Apr 2011 17:21:55 +0200
Subject: [PATCH 1/2] Replace char class :space: with explicit chars
In-Reply-To: <cover.1304090389.git.zkabelac@redhat.com>
References: <cover.1304090389.git.zkabelac@redhat.com>
Message-ID: <f6d906830b6cde0d2617267cc0d5f4abd2184b71.1304090389.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As some distributions are using 'mawk' and they are not using the latest
version - we end here with hidden dependency on the latest version of
mawk (1.3.4).  Some distributions like Debian Lenny seems to stay with 1.3.3.
So we end with completely broken  vgimportclone script on such system.
(From the plain look at http://packages.debian.org/search?keywords=mawk
it still looks like the 1.3.3 is the last available package in Debian)

We have 2 options:
 - check for proper support of :space: and abort if it doesn't work
 - replace [:space:] with [ \t] which seems sufficint to make it work
   (as can be seen in this patch)

This patch makes t-vgimportclone.sh test passing on Lenny.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/vgimportclone.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 731b860..75c1175 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -245,10 +245,10 @@ LVMCONF=${TMP_LVM_SYSTEM_DIR}/lvm.conf
 "$LVM" dumpconfig ${LVM_OPTS} | \
 "$AWK" -v DEV=${TMP_LVM_SYSTEM_DIR} -v CACHE=${TMP_LVM_SYSTEM_DIR}/.cache \
     -v CACHE_DIR=${TMP_LVM_SYSTEM_DIR}/cache \
-    '/^[[:space:]]*filter[[:space:]]*=/{print ENVIRON["FILTER"];next} \
-     /^[[:space:]]*scan[[:space:]]*=/{print "scan = [ \"" DEV "\" ]";next} \
-     /^[[:space:]]*cache[[:space:]]*=/{print "cache = \"" CACHE "\"";next} \
-     /^[[:space:]]*cache_dir[[:space:]]*=/{print "cache_dir = \"" CACHE_DIR "\"";next} \
+    '/^[ \t]*filter[ \t]*=/{print ENVIRON["FILTER"];next} \
+     /^[ \t]*scan[ \t]*=/{print "scan = [ \"" DEV "\" ]";next} \
+     /^[ \t]*cache[ \t]*=/{print "cache = \"" CACHE "\"";next} \
+     /^[ \t]*cache_dir[ \t]*=/{print "cache_dir = \"" CACHE_DIR "\"";next} \
      {print $0}' > ${LVMCONF}
 
 checkvalue $? "Failed to generate ${LVMCONF}"
@@ -282,7 +282,7 @@ checkvalue $? "PV info could not be collected without errors"
 
 # output VG info so each line looks like: name:exported?:disk1,disk2,...
 VGINFO=`echo "${PVINFO}" | \
-    "$AWK" -F : '{{sub(/^[[:space:]]*/,"")} \
+    "$AWK" -F : '{{sub(/^[ \t]*/,"")} \
     {sub(/unknown device/,"unknown_device")} \
     {vg[$2]=$1","vg[$2]} if($3 ~ /^..x/){x[$2]="x"}} \
     END{for(k in vg){printf("%s:%s:%s\n", k, x[k], vg[k])}}'`
-- 
1.7.5


