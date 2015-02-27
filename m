From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 27 Feb 2015 08:16:02 +0000 (UTC)
Subject: master - conf: be more clear about wipe_signatures_when_zeroing_new_lvs option in comments
Message-ID: <20150227081602.A715060DDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bceb1e0bb460a728638aea179b000f07b4cbd0b
Commit:        8bceb1e0bb460a728638aea179b000f07b4cbd0b
Parent:        0a19238aa30a3a594abaa544c4972c880cefafe1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 27 08:53:15 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 27 09:17:10 2015 +0100

conf: be more clear about wipe_signatures_when_zeroing_new_lvs option in comments

---
 conf/example.conf.in |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 1f10dad..51e8e85 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -330,13 +330,28 @@ allocation {
     # to be recognized, it can take more time to complete the signature scan.
     use_blkid_wiping = 1
 
-    # Set to 1 to wipe any signatures found on newly-created Logical Volumes
-    # automatically in addition to zeroing of the first KB on the LV
-    # (controlled by the -Z/--zero y option).
-    # The command line option -W/--wipesignatures takes precedence over this
-    # setting.
-    # The default is to wipe signatures when zeroing.
-    #
+    # Set to 1 to detect any signatures found on newly-created Logical Volume
+    # whenever zeroing of the LV is done (zeroing is controlled by -Z/--zero
+    # option and if not specified, zeroing is used by default if possible).
+    #
+    # While zeroing simply overwrites first 4 KiB of the LV with zeroes without
+    # doing any signature detection, signature wiping goes beyond that and it
+    # can detect exact type and position of signature within the whole LV.
+    # As such, it provides cleaner LV for use after creation as all known
+    # signatures are wiped so that the LV is not claimed by other tools
+    # incorrectly by the existence of old signature from any previous use.
+    # The number of signatures that LVM can detect depends on detection
+    # code that is selected - see also use_blkid_wiping option.
+    #
+    # Wiping of each detected signature must be confirmed.
+    #
+    # The default is to wipe signatures when zeroing. The command line
+    # option -W/--wipesignatures takes precedence over this setting.
+    #
+    # Without this option set, signatures on newly-created Logical Volumes
+    # are never detected and wiped and you always need to use
+    # -W/--wipesignatures y option directly to enable this feature
+    # no matter whether zeroing is used or not.
     wipe_signatures_when_zeroing_new_lvs = 1
 
     # Set to 1 to guarantee that mirror logs will always be placed on 


