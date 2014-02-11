From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Feb 2014 12:49:27 +0000 (UTC)
Subject: master - cleanup: clarify man pages about lvchange/vgchange -aay, use -aay in lvm2-cluster-activation script
Message-ID: <20140211124927.6361661106@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a5062c9a7136f93a00b998ff0de1a32bb347b5f
Commit:        1a5062c9a7136f93a00b998ff0de1a32bb347b5f
Parent:        a092cd33be13229b288ab44fb39e410c1ca57175
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 11 13:48:04 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 11 13:48:04 2014 +0100

cleanup: clarify man pages about lvchange/vgchange -aay, use -aay in lvm2-cluster-activation script

---
 WHATS_NEW                                     |    2 +-
 man/lvchange.8.in                             |    5 +++--
 man/vgchange.8.in                             |    7 ++++---
 scripts/lvm2_cluster_activation_red_hat.sh.in |    4 +++-
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c5bb6de..918123f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.106 - 
 ====================================
-  Add systemd native service for clvmd, cmirrord and cluster activation.
+  Add systemd native service for clvmd, cmirrord and clustered LV activation.
   Remove ExecReload from lvmetad systemd unit: lvmetad -R undefined. (2.02.98)
   Do not fork lvmetad if running under systemd.
   Wipe DM_snapshot_cow signature without prompt in new LVs with blkid wiping.
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 49337e4..64231c8 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -74,8 +74,9 @@ logical volumes. If autoactivation option is used (\-aay),
 the logical volume is activated only if it matches an item in
 the activation/auto_activation_volume_list set in lvm.conf.
 If this list is not set, then all volumes are considered for
-autoactivation. The autoactivation is not yet supported for
-logical volumes that are part of partial or clustered volume groups.
+activation. The \-aay option should be also used during system
+boot so it's possible to select which volumes to activate using
+the activation/auto_activation_volume_list setting.
 .IP
 If clustered locking is enabled, -aey will activate exclusively
 on one node and -aly will activate only on the local node.
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 823d134..16adf4df 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -76,9 +76,10 @@ In other words, makes the logical volumes known/unknown to the kernel.
 If autoactivation option is used (\-aay), each logical volume in
 the volume group is activated only if it matches an item in the
 activation/auto_activation_volume_list set in lvm.conf. If this
-list is not set, then all volumes are considered for autoactivation.
-The autoactivation is not yet supported for partial or clustered
-volume groups.
+list is not set, then all volumes are considered for activation.
+The \-aay option should be also used during system boot so it's
+possible to select which volumes to activate using the
+activation/auto_activation_volume_list settting.
 .IP
 If clustered locking is enabled, add 'e' to activate/deactivate
 exclusively on one node or 'l' to activate/deactivate only
diff --git a/scripts/lvm2_cluster_activation_red_hat.sh.in b/scripts/lvm2_cluster_activation_red_hat.sh.in
index 2531ef2..0d4676c 100644
--- a/scripts/lvm2_cluster_activation_red_hat.sh.in
+++ b/scripts/lvm2_cluster_activation_red_hat.sh.in
@@ -31,7 +31,9 @@ activate() {
 	fi
 
 	echo -n "Activating ${LVM_VGS:-"all VG(s)"}: "
-        ${lvm_vgchange} -ayl $LVM_VGS || return 1
+	# Respect activation/auto_activation_volume_list!
+	# Call "-aay" which is equal to "-aly" but respects this list.
+        ${lvm_vgchange} -aay $LVM_VGS || return 1
 
 	return 0
 }


