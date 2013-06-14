From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 14 Jun 2013 10:35:55 +0000 (UTC)
Subject: master - conf: refine lvm.conf documentation for autoactivation feature even more
Message-ID: <20130614103555.D6EA16031B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53b405093b7c13235589b2778f9236e2aabcae61
Commit:        53b405093b7c13235589b2778f9236e2aabcae61
Parent:        19369cf7f33ffc4da43b7809e4bcc1a989a9d406
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 14 12:35:06 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 14 12:35:06 2013 +0200

conf: refine lvm.conf documentation for autoactivation feature even more

---
 doc/example.conf.in |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 5b7ed5b..94c32d5 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -662,13 +662,20 @@ activation {
     #     In this case, the user calls "vgchange --activate ay/-a ay" or
     #     "lvchange --activate ay/-a ay" directly.
     #
-    # If the VG/LV being processed does not match the list, the VG/LV is not
-    # activated. If auto_activation_volume_list is not set, then all volumes
-    # are activated by default.
+    # By default, the auto_activation_volume_list is not defined and all
+    # volumes will be activated either automatically or by using --activate ay/-a ay.
     #
     # N.B. The "activation/volume_list" is still honoured in all cases so even
     # if the VG/LV passes the auto_activation_volume_list, it still needs to
     # pass the volume_list for it to be activated in the end.
+
+    # If auto_activation_volume_list is defined but empty, no volumes will be
+    # activated automatically and --activate ay/-a ay will do nothing.
+    #
+    # auto_activation_volume_list = []
+
+    # If auto_activation_volume_list is defined and it's not empty, only matching
+    # volumes will be activated either automatically or by using --activate ay/-a ay.
     #
     #   "vgname" and "vgname/lvname" are matched exactly.
     #   "@tag" matches any tag set in the LV or VG.


