From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 16:49:51 +0000 (UTC)
Subject: master - cleanup: remove goto
Message-ID: <20161103164951.8915260F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d95082aa97b92d120daf1858acd91abe788d2cb
Commit:        0d95082aa97b92d120daf1858acd91abe788d2cb
Parent:        9cbe4c1af935bd4e76fbcc8a8736c6337bfc638b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 26 11:26:02 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 17:49:07 2016 +0100

cleanup: remove goto

Move goto path into 'if()' branch.
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 7653413..a7ed4dd 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -73,8 +73,10 @@ static int _get_mirror_event(struct dso_state *state, char *params)
 	unsigned i;
 	struct dm_status_mirror *ms;
 
-	if (!dm_get_status_mirror(state->mem, params, &ms))
-		goto_out;
+	if (!dm_get_status_mirror(state->mem, params, &ms)) {
+		log_error("Unable to parse mirror status string.");
+		return ME_IGNORE;
+	}
 
 	/* Check for bad mirror devices */
 	for (i = 0; i < ms->dev_count; ++i)
@@ -95,11 +97,6 @@ static int _get_mirror_event(struct dso_state *state, char *params)
 	dm_pool_free(state->mem, ms);
 
 	return r;
-
-out:
-	log_error("Unable to parse mirror status string.");
-
-	return ME_IGNORE;
 }
 
 static int _remove_failed_devices(const char *cmd_lvscan, const char *cmd_lvconvert)


