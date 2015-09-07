From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  7 Sep 2015 11:15:20 +0000 (UTC)
Subject: master - libdm: fix dm_stats leak in dm_stats_create()
Message-ID: <20150907111520.A8A0660EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab1b54c3e3244c481a1f8bf5e7c8b48870846bd8
Commit:        ab1b54c3e3244c481a1f8bf5e7c8b48870846bd8
Parent:        0f5933ecc1bf792a404e2cdfa8a2eccf66b5b6e1
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 7 12:08:34 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 7 12:08:34 2015 +0100

libdm: fix dm_stats leak in dm_stats_create()

The histogram changes adds a new error path to dm_stats_create().
Make sure that the dm_stats handle is properly destroyed if we fail
to create the histogram pool and check for failures setting the
program_id.
---
 libdm/libdm-stats.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index bb26c46..20e3c9b 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -144,17 +144,24 @@ struct dm_stats *dm_stats_create(const char *program_id)
 		return_NULL;
 
 	/* FIXME: better hint. */
-	if (!(dms->mem = dm_pool_create("stats_pool", 4096)))
-		goto_bad;
+	if (!(dms->mem = dm_pool_create("stats_pool", 4096))) {
+		dm_free(dms);
+		return_NULL;
+	}
 
 	if (!(dms->hist_mem = dm_pool_create("histogram_pool", hist_hint)))
-		return_0;
+		goto_bad;
 
 	if (!program_id || !strlen(program_id))
 		dms->program_id = _program_id_from_proc();
 	else
 		dms->program_id = dm_strdup(program_id);
 
+	if (!dms->program_id) {
+		dm_pool_destroy(dms->hist_mem);
+		goto_bad;
+	}
+
 	dms->major = -1;
 	dms->minor = -1;
 	dms->name = NULL;
@@ -171,6 +178,7 @@ struct dm_stats *dm_stats_create(const char *program_id)
 	return dms;
 
 bad:
+	dm_pool_destroy(dms->mem);
 	dm_free(dms);
 	return NULL;
 }


