From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 Apr 2016 21:14:00 +0000 (UTC)
Subject: master - lvchange: improve refresh for merging thin volume
Message-ID: <20160418211400.C798961E15@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88c19d5d7200b4193693f88f42e05646a52b4563
Commit:        88c19d5d7200b4193693f88f42e05646a52b4563
Parent:        7e5881dd131e6f521f8f419edc3bb42e575d693a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 18 22:44:30 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 18 23:05:51 2016 +0200

lvchange: improve refresh for merging thin volume

When running lvchange --refresh on merging thin volume,
try to deactivate snapshot thinLV in case it's preventing
startup of merge process.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 863fe30..4a435bb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151 -
 =================================
+  lvchange --refresh for merging thin origin will retry to deactivate snapshot.
   Recognize in-progress snapshot merge for thin volumes from dm table.
   Avoid deciding to initiate a pending snapshot merge during resume.
   Improve retrying lvmetad requests while lvmetad is being updated.
diff --git a/tools/toollib.c b/tools/toollib.c
index 5e9b4d8..b9db9cb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1080,6 +1080,16 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
+	struct logical_volume *snapshot_lv;
+
+	if (lv_is_merging_origin(lv)) {
+		snapshot_lv = find_snapshot(lv)->lv;
+		if (lv_is_thin_type(snapshot_lv) && !deactivate_lv(cmd, snapshot_lv))
+			log_print_unless_silent("Delaying merge for origin volume %s since "
+						"snapshot volume %s is still active.",
+						display_lvname(lv), display_lvname(snapshot_lv));
+	}
+
 	if (!lv_refresh_suspend_resume(cmd, lv))
 		return_0;
 


