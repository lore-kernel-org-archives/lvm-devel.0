From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 10 Aug 2015 20:51:10 +0000 (UTC)
Subject: master - lvrename: fix lockd LV locking
Message-ID: <20150810205110.E584560D17@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53c08f0bba9f18df80403eab67acb032f3049902
Commit:        53c08f0bba9f18df80403eab67acb032f3049902
Parent:        597de9d58673f141bf21aa9db899d13ca2c97b7b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 10 15:46:21 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 10 15:46:21 2015 -0500

lvrename: fix lockd LV locking

lvrename should not be done if the LV is active on another host.
This check was mistakenly removed when the code was changed to
use LV uuids in locks rather than LV names.
---
 lib/metadata/lv_manip.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 86411d5..b22773e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4205,6 +4205,18 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	/*
+	 * The lvmlockd LV lock is only acquired here to ensure the LV is not
+	 * active on another host.  This requests a transient LV lock.
+	 * If the LV is active, a persistent LV lock already exists in
+	 * lvmlockd, and the transient lock request does nothing.
+	 * If the LV is not active, then no LV lock exists and the transient
+	 * lock request acquires the LV lock (or fails).  The transient lock
+	 * is automatically released when the command exits.
+	 */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_0;
+
 	if (update_mda && !archive(vg))
 		return_0;
 


