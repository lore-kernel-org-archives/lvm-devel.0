From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 Nov 2013 12:05:48 +0000 (UTC)
Subject: master - activation: _lv_activate is ok when filtered.
Message-ID: <20131101120548.DB7C461028@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3e674ad3010d21dc2cbde27b7634f7ea4fe67e3
Commit:        c3e674ad3010d21dc2cbde27b7634f7ea4fe67e3
Parent:        1bde9f68cea61c7ee085588f2595ed52277da084
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 10:28:42 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 13:02:36 2013 +0100

activation: _lv_activate is ok when filtered.

If the volume_list filters out volume from activation,
it is still success result for this function.
Change the error message back to verbose level.

Detect if the volume is active localy before zeroing,
so we report error a bit later for cases, where volume
could not be activated because it doesn't pass through volume
list  (but user still could create volume when he disables
zeroing)
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    5 +++--
 lib/metadata/lv_manip.c |    6 ++++++
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2bf95d2..ff8da1d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104 -
 ===================================
+  Return success when LV cannot be activated because of volume_list filter.
   Return proper error state for remote exclusive activation.
   Fix missing lvmetad scan for PVs found on MD partitions.
   Respect DM_UDEV_DISABLE_OTHER_RULES_FLAG in lvmetad udev rules.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 006681e..7e6a5ac 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2029,8 +2029,9 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		goto out;
 
 	if (filter && !_passes_activation_filter(cmd, lv)) {
-		log_error("Not activating %s/%s since it does not pass "
-			  "activation filter.", lv->vg->name, lv->name);
+		log_verbose("Not activating %s/%s since it does not pass "
+			    "activation filter.", lv->vg->name, lv->name);
+		r = 1;
 		goto out;
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 88fceb2..020b365 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5381,6 +5381,12 @@ int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	struct device *dev;
 	char *name;
 
+	if (!lv_is_active_locally(lv)) {
+		log_error("Volume \"%s/%s\" is not active locally.",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
 	/*
 	 * FIXME:
 	 * <clausen> also, more than 4k


