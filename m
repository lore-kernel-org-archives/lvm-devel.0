From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Nov 2015 20:42:07 +0000 (UTC)
Subject: master - libdm: reorder error path
Message-ID: <20151110204207.0665260DEF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d0db97163125b6f4c7e07b6aba2f27dd050d14b
Commit:        6d0db97163125b6f4c7e07b6aba2f27dd050d14b
Parent:        a45cc0fe1460168f2e193c210aabaa1292fe0ea3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 10 21:34:31 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 10 21:41:47 2015 +0100

libdm: reorder error path

Coverity noticed recent fix of an error path missed to
release 'dmt' - reoder code to ensure 'dmt' is released.
---
 libdm/libdm-stats.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 1811e8a..3a21093 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1270,13 +1270,12 @@ char *dm_stats_print_region(struct dm_stats *dms, uint64_t region_id,
 		return_0;
 
 	if (!(response = dm_task_get_message_response(dmt)))
-		return_0;
-
-	resp = dm_pool_strdup(dms->mem, response);
-	dm_task_destroy(dmt);
+		goto_out;
 
-	if (!resp)
+	if (!(resp = dm_pool_strdup(dms->mem, response)))
 		log_error("Could not allocate memory for response buffer.");
+out:
+	dm_task_destroy(dmt);
 
 	return resp;
 }


