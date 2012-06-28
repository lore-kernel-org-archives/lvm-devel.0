From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Jun 2012 13:49:14 +0000 (UTC)
Subject: master - conf: add activation/auto_activation_volume_list
Message-ID: <20120628134914.2AB111734@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6a3ef4490ebcb2318fd98e79add2c910cf482c5
Commit:        f6a3ef4490ebcb2318fd98e79add2c910cf482c5
Parent:        a2f4ccd83907590d16e6d06e1aea7e70efcf1fe5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 26 06:17:23 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 28 09:44:07 2012 -0400

conf: add activation/auto_activation_volume_list

---
 WHATS_NEW           |    1 +
 doc/example.conf.in |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 152ec08..842a188 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add activation/auto_activation_volume_list to lvm.conf.
   Add --activate ay to lvcreate.
   Add --activate ay to lvchange.
   Add --activate ay to pvscan.
diff --git a/doc/example.conf.in b/doc/example.conf.in
index 9092e32..4864b81 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -550,6 +550,15 @@ activation {
     #
     # volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 
+    # If auto_activation_volume_list is defined, each LV that is to be activated
+    # is checked against the list while using the --autoactivate option, and if
+    # it matches, it is activated.
+    #   "vgname" and "vgname/lvname" are matched exactly.
+    #   "@tag" matches any tag set in the LV or VG.
+    #   "@*" matches if any tag defined on the host is also set in the LV or VG
+    #
+    # auto_activation_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
+
     # If read_only_volume_list is defined, each LV that is to be activated 
     # is checked against the list, and if it matches, it as activated
     # in read-only mode.  (This overrides '--permission rw' stored in the


