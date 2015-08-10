From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 10 Aug 2015 19:30:27 +0000 (UTC)
Subject: master - libdm: fix stats handle leak in dm_stats_create (Coverity)
Message-ID: <20150810193027.86A7C6022D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9f5aac123d2244daeff92a692a03da3fea6bd74
Commit:        f9f5aac123d2244daeff92a692a03da3fea6bd74
Parent:        1134de3c89c5a07699365031d0cb88383e365929
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 10 10:15:22 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 10 20:20:30 2015 +0100

libdm: fix stats handle leak in dm_stats_create (Coverity)

Make sure the newly created handle is freed if we are unable to
also create the pool for it.

tools/dmsetup.c: 4255 in _stats_list() - Variable "dms" going out of scope leaks the storage it points to.
---
 libdm/libdm-stats.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 64ca23f..a672e05 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -94,10 +94,10 @@ struct dm_stats *dm_stats_create(const char *program_id)
 {
 	struct dm_stats *dms = NULL;
 
-	if (!(dms = dm_malloc(sizeof(*dms))))
+	if (!(dms = dm_zalloc(sizeof(*dms))))
 		return_NULL;
 	if (!(dms->mem = dm_pool_create("stats_pool", 4096)))
-		return_NULL;
+		goto_out;
 
 	if (!program_id || !strlen(program_id))
 		dms->program_id = _program_id_from_proc();
@@ -117,6 +117,9 @@ struct dm_stats *dm_stats_create(const char *program_id)
 	dms->regions = NULL;
 
 	return dms;
+out:
+	dm_free(dms);
+	return NULL;
 }
 
 /**


