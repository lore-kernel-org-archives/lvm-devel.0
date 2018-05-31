From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:45 -0400
Subject: master - tests: vgchange-usage update for lvmlockd
Message-ID: <201805311414.w4VEEjOg031221@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a40d447a02521820c23422fdd43f795c32d402a7
Commit:        a40d447a02521820c23422fdd43f795c32d402a7
Parent:        95cf127134c93882f78d13d26a87e28f2c256d34
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 25 14:34:38 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

tests: vgchange-usage update for lvmlockd

---
 test/shell/vgchange-usage.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 1520142..1885a64 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -11,7 +11,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 test_description='Exercise some vgchange diagnostics'
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -19,7 +19,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 4
 
 pvcreate --metadatacopies 0 "$dev1"
-vgcreate -s 4M $vg "$dev1" "$dev2" "$dev3"
+vgcreate $SHARED -s 4M $vg "$dev1" "$dev2" "$dev3"
 
 # cannot change anything in exported vg
 vgexport $vg
@@ -97,6 +97,9 @@ fail vgchange -x n $vg
 fail vgextend $vg "$dev4"
 vgremove -ff $vg
 
+# skip cluster tests with lvmlockd
+test -n "$LVM_TEST_LVMLOCKD" && exit 0
+
 # set cluster bit
 vgcreate -cn $vg "$dev1" "$dev2" "$dev3"
 # check prompt to change cluster bit without giving explicit vg name


