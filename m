From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 18 Apr 2014 01:48:05 +0000 (UTC)
Subject: master - metadata: Fix unlock on VG recovery error path.
Message-ID: <20140418014805.D6EF360317@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17e304e0ac24ba0d1887badfb51afa731aa138e9
Commit:        17e304e0ac24ba0d1887badfb51afa731aa138e9
Parent:        177ece01a9b67c60818049084555a877f9e236e0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 18 02:27:16 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 18 02:27:16 2014 +0100

metadata: Fix unlock on VG recovery error path.

If lock conversion failed it tried to unlock VG that was no longer locked.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 62f0959..ac18601 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Fix _recover_vg() error path when lock conversion fails.
   Use X for LV attributes that are unknown when activation disabled.
   Only output lvdisplay 'LV Status' field when activation is enabled.
   Use lvmetad_used() in pvscan instead of config_tree.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 643613f..6bc7e3a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4105,6 +4105,9 @@ int vg_check_status(const struct volume_group *vg, uint64_t status)
 	return !_vg_bad_status_bits(vg, status);
 }
 
+/*
+ * VG is left unlocked on failure
+ */
 static struct volume_group *_recover_vg(struct cmd_context *cmd,
 			 const char *vg_name, const char *vgid)
 {
@@ -4118,11 +4121,14 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL))
 		return_NULL;
 
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, 1, &consistent)))
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, 1, &consistent))) {
+		unlock_vg(cmd, vg_name);
 		return_NULL;
+	}
 
 	if (!consistent) {
 		release_vg(vg);
+		unlock_vg(cmd, vg_name);
 		return_NULL;
 	}
 
@@ -4202,7 +4208,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
 			failure |= FAILED_INCONSISTENT;
-			goto bad;
+			goto bad_no_unlock;
 		}
 	}
 
@@ -4237,6 +4243,7 @@ bad:
 	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK))
 		unlock_vg(cmd, vg_name);
 
+bad_no_unlock:
 	return _vg_make_handle(cmd, vg, failure);
 }
 


