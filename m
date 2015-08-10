From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 10 Aug 2015 19:30:33 +0000 (UTC)
Subject: master - libdm-stats: backtrace if fclose fails (Coverity)
Message-ID: <20150810193033.CE6CB61021@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f072a7632655d0541b56858d5fbe172fa6075e68
Commit:        f072a7632655d0541b56858d5fbe172fa6075e68
Parent:        856f9cced83078a90ca2291eff0758d42775f195
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 10 19:23:41 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 10 20:26:07 2015 +0100

libdm-stats: backtrace if fclose fails (Coverity)

Since libdm-stats only uses fmemopen'd FILE objects the only way
that a close can fail is corruption of the memory containing the
FILE: check for this case and emit a backtrace if it occurs.

libdm/libdm-stats.c: 338 in _stats_parse_list()
libdm/libdm-stats.c: 341 in _stats_parse_list()
libdm/libdm-stats.c: 481 in _stats_parse_region()
libdm/libdm-stats.c: 487 in _stats_parse_region()
libdm/libdm-stats.c: 487 in _stats_parse_region()
 - Calling "fclose" without checking return value
---
 libdm/libdm-stats.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 192326e..ea4feef 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -81,11 +81,13 @@ static char *_program_id_from_proc(void)
 
 	if (!fgets(buf, sizeof(buf), comm)) {
 		log_error("Could not read from %s", PROC_SELF_COMM);
-		fclose(comm);
+		if(fclose(comm))
+			stack;
 		return NULL;
 	}
 
-	fclose(comm);
+	if (fclose(comm))
+		stack;
 
 	return dm_strdup(buf);
 }
@@ -340,10 +342,13 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 	dms->max_region = max_region - 1;
 	dms->regions = dm_pool_end_object(mem);
 
-	fclose(list_rows);
+	if (fclose(list_rows))
+		stack;
+
 	return 1;
 out:
-	fclose(list_rows);
+	if(fclose(list_rows))
+		stack;
 	dm_pool_abandon_object(mem);
 	return 0;
 }
@@ -483,13 +488,16 @@ static int _stats_parse_region(struct dm_pool *mem, const char *resp,
 	region->timescale = timescale;
 	region->counters = dm_pool_end_object(mem);
 
-	fclose(stats_rows);
+	if (fclose(stats_rows))
+		stack;
+
 	return 1;
 
 out:
 
 	if (stats_rows)
-		fclose(stats_rows);
+		if(fclose(stats_rows))
+			stack;
 	dm_pool_abandon_object(mem);
 	return 0;
 }


