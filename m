From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 14 Jun 2013 08:07:34 +0000 (UTC)
Subject: master - typo: lvm.conf: auto_activation_list -> auto_activation_volume_list
Message-ID: <20130614080734.700B86147D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19369cf7f33ffc4da43b7809e4bcc1a989a9d406
Commit:        19369cf7f33ffc4da43b7809e4bcc1a989a9d406
Parent:        dba53681a5d31c7f9510cf64637e2fbc707fb899
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 14 10:07:07 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 14 10:07:07 2013 +0200

typo: lvm.conf: auto_activation_list -> auto_activation_volume_list

---
 doc/example.conf.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 7800d15..5b7ed5b 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -655,7 +655,7 @@ activation {
     #     is triggered. This requires lvmetad (global/use_lvmetad=1) and udev
     #     to be running. In this case, "pvscan --cache -aay" is called
     #     automatically without any user intervention while processing
-    #     udev events. Please, make sure you define auto_activation_list
+    #     udev events. Please, make sure you define auto_activation_volume_list
     #     properly so only the volumes you want and expect are autoactivated.
     #
     #   - direct activation on command line with the autoactivation option.


