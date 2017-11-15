From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:43 -0500
Subject: master - activation: check subLV before skipping resume
Message-ID: <201711151309.vAFD9hXo001962@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e2a68a981a44579b19108554b8f89a860eb9d59
Commit:        9e2a68a981a44579b19108554b8f89a860eb9d59
Parent:        c820b43fc053689eac0a60cd732347c8eb30ad5d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 10 21:15:50 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 14:03:22 2017 +0100

activation: check subLV before skipping resume

LV is asked for resume, and its already resume and tool
is inside 'critical_section()' check if there is any suspended sub LV.
In that case 'resume' operation will not be skipped.
---
 lib/activate/activate.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 5542f84..05aea85 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2276,6 +2276,17 @@ int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned o
 	return _lv_suspend(cmd, lvid_s, &laopts, 0, lv, lv_pre);
 }
 
+static int _check_suspended_lv(struct logical_volume *lv, void *data)
+{
+	struct lvinfo info;
+
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists && info.suspended) {
+		log_debug("Found suspended LV %s in critical section().", display_lvname(lv));
+		return 0; /* There is suspended subLV in the tree */
+	}
+
+	return 1;
+}
 
 static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		      struct lv_activate_opts *laopts, int error_if_not_active,
@@ -2315,10 +2326,18 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	if (!info.exists || !info.suspended) {
 		if (error_if_not_active)
 			goto_out;
-		r = 1;
-		if (!info.suspended)
-			critical_section_dec(cmd, "already resumed");
-		goto out;
+
+		if (!info.suspended && critical_section()) {
+			/* check if any subLV is suspended */
+			if ((r = for_each_sub_lv((struct logical_volume *)lv, &_check_suspended_lv, NULL))) {
+				/* Everything seems resumed */
+				critical_section_dec(cmd, "already resumed");
+				goto out;
+			}
+		} else {
+			r = 1;
+			goto out;
+		}
 	}
 
 	laopts->read_only = _passes_readonly_filter(cmd, lv);


