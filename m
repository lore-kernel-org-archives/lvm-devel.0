From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Dec 2013 09:17:23 +0000 (UTC)
Subject: master - conf: clarify wipe_signatures_when_zeroing_new_lvs
Message-ID: <20131210091723.217E960D63@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0fcdc8a020afcafa182da93922c171604cf3035e
Commit:        0fcdc8a020afcafa182da93922c171604cf3035e
Parent:        16eab3ec08e72bb3fb58dd2af4bfec786315919a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 10 10:16:37 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 10 10:16:37 2013 +0100

conf: clarify wipe_signatures_when_zeroing_new_lvs

---
 conf/example.conf.in |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index dcbc0b3..0c2fc0a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -287,10 +287,10 @@ allocation {
     # to be recognized, it can take more time to complete the signature scan.
     use_blkid_wiping = 1
 
-    # Set to 1 when use_blkid_wiping is enabled to wipe any signatures found on
-    # newly-created Logical Volumes automatically in addition to zeroing of the
-    # first KB on the LV (controlled by the -Z/--zero y option).
-    # The command line option -W/--wipesignatures n takes precedence over this
+    # Set to 1 to wipe any signatures found on newly-created Logical Volumes
+    # automatically in addition to zeroing of the first KB on the LV
+    # (controlled by the -Z/--zero y option).
+    # The command line option -W/--wipesignatures takes precedence over this
     # setting.
     # The default is to wipe signatures when zeroing.
     #


