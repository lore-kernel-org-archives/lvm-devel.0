From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 16:49:55 +0000 (UTC)
Subject: master - dmeventd: provide message context
Message-ID: <20161103164955.B007860910@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9ee86ccf2425cbe3f038039c8038db1e1784086
Commit:        a9ee86ccf2425cbe3f038039c8038db1e1784086
Parent:        4e26024add915a1970eb7f43298b24b180e7e061
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 26 12:13:34 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 17:49:07 2016 +0100

dmeventd: provide message context

Show device name with printed message.
Also use different level for printing error message and
standard informational message.
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index a7ed4dd..3d3a6de 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -99,20 +99,21 @@ static int _get_mirror_event(struct dso_state *state, char *params)
 	return r;
 }
 
-static int _remove_failed_devices(const char *cmd_lvscan, const char *cmd_lvconvert)
+static int _remove_failed_devices(const char *cmd_lvscan, const char *cmd_lvconvert,
+				  const char *device)
 {
-	int r;
-
 	if (!dmeventd_lvm2_run_with_lock(cmd_lvscan))
-		log_warn("WARNING: Re-scan of mirrored device failed.");
+		log_warn("WARNING: Re-scan of mirrored device %s failed.", device);
 
 	/* if repair goes OK, report success even if lvscan has failed */
-	r = dmeventd_lvm2_run_with_lock(cmd_lvconvert);
+	if (!dmeventd_lvm2_run_with_lock(cmd_lvconvert)) {
+		log_error("Repair of mirrored device %s failed.", device);
+		return 0;
+	}
 
-	log_info("Repair of mirrored device %s.",
-		 (r) ? "finished successfully" : "failed");
+	log_info("Repair of mirrored device %s finished successfully.", device);
 
-	return r;
+	return 1;
 }
 
 void process_event(struct dm_task *dmt,
@@ -151,7 +152,8 @@ void process_event(struct dm_task *dmt,
 		case ME_FAILURE:
 			log_error("Device failure in %s.", device);
 			if (!_remove_failed_devices(state->cmd_lvscan,
-						    state->cmd_lvconvert))
+						    state->cmd_lvconvert,
+						    device))
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
 				log_error("Failed to remove faulty devices in %s.",
 					  device);


