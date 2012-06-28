From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Jun 2012 13:49:16 +0000 (UTC)
Subject: master - initscript: call vgchange -aay instead of -aly
Message-ID: <20120628134916.8890C173A@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d5adc5823353cba2bd3e585bb75a4a298f4cbfd
Commit:        2d5adc5823353cba2bd3e585bb75a4a298f4cbfd
Parent:        f6a3ef4490ebcb2318fd98e79add2c910cf482c5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 28 12:49:33 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 28 09:44:07 2012 -0400

initscript: call vgchange -aay instead of -aly

The clmvd init script called "vgchange -aly" before to activate
all VGs in cluster environment. This activated all VGs, no matter
if it was clustered or not.

Auto activation for clustered VGs is not supported yet so the behaviour
of -aay is still the same as before for clustered VGs. However, for
non-clustered VGs, we need to check with the activation/auto_activation_volume_list
whether the VG/LV should be activated on boot or not.
---
 WHATS_NEW                     |    1 +
 scripts/clvmd_init_red_hat.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 842a188..4a6df08 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Use vgchange -aay instead of vgchange -ay in clmvd init script.
   Add activation/auto_activation_volume_list to lvm.conf.
   Add --activate ay to lvcreate.
   Add --activate ay to lvchange.
diff --git a/scripts/clvmd_init_red_hat.in b/scripts/clvmd_init_red_hat.in
index 3fc90c5..4170094 100644
--- a/scripts/clvmd_init_red_hat.in
+++ b/scripts/clvmd_init_red_hat.in
@@ -87,7 +87,7 @@ start()
 
 	${lvm_vgscan} > /dev/null 2>&1
 
-	action "Activating VG(s):" ${lvm_vgchange} -ayl $LVM_VGS || return $?
+	action "Activating VG(s):" ${lvm_vgchange} -aay $LVM_VGS || return $?
 
 	touch $LOCK_FILE
 


