From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:03:01 -0400
Subject: master - coverity: ensure 0 end string
Message-ID: <201804201103.w3KB31bj031459@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa5ba7e42d409532ddeea97c5802f042e40935b2
Commit:        fa5ba7e42d409532ddeea97c5802f042e40935b2
Parent:        037c234eaaabd4989e769e1f9db47c8452fa4966
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 29 19:07:31 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

coverity: ensure 0 end string

Use dm_strncpy() to enusure string ends with '\0'.
In case uuid does not fit, report error.
---
 daemons/cmirrord/cluster.c   |    2 +-
 daemons/cmirrord/functions.c |   10 +++++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index e56d8f3..180e34a 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -1631,7 +1631,7 @@ int create_cluster_cpg(char *uuid, uint64_t luid)
 
 	size = ((strlen(uuid) + 1) > CPG_MAX_NAME_LENGTH) ?
 		CPG_MAX_NAME_LENGTH : (strlen(uuid) + 1);
-	strncpy(new->name.value, uuid, size);
+	(void) dm_strncpy(new->name.value, uuid, size);
 	new->name.length = (uint32_t)size;
 	new->luid = luid;
 
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 03f8626..5e43e1a 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -451,15 +451,19 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 	lc->skip_bit_warning = region_count;
 	lc->disk_fd = -1;
 	lc->log_dev_failed = 0;
-	strncpy(lc->uuid, uuid, DM_UUID_LEN);
+	if (!dm_strncpy(lc->uuid, uuid, DM_UUID_LEN)) {
+		LOG_ERROR("Cannot use too long UUID %s.", uuid);
+		r = -EINVAL;
+		goto fail;
+	}
 	lc->luid = luid;
 
 	if (get_log(lc->uuid, lc->luid) ||
 	    get_pending_log(lc->uuid, lc->luid)) {
 		LOG_ERROR("[%s/%" PRIu64 "u] Log already exists, unable to create.",
 			  SHORT_UUID(lc->uuid), lc->luid);
-		dm_free(lc);
-		return -EINVAL;
+		r = -EINVAL;
+		goto fail;
 	}
 
 	dm_list_init(&lc->mark_list);


