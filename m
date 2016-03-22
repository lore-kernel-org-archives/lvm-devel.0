From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Mar 2016 21:41:25 +0000 (UTC)
Subject: master - raid: Tidy dm_get_status_raid. [HM]
Message-ID: <20160322214125.29B1560FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1056894f1f1d48eb295d283859473cd9bc6b9df5
Commit:        1056894f1f1d48eb295d283859473cd9bc6b9df5
Parent:        cf393466976a226faba924c6d14fa04bd7b37c89
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Mar 22 21:39:52 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Mar 22 21:39:52 2016 +0000

raid: Tidy dm_get_status_raid. [HM]

---
 libdm/libdm-targets.c |   89 +++++++++++++++++++++++++++++-------------------
 1 files changed, 54 insertions(+), 35 deletions(-)

diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 8a8a328..b91c7e9 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -67,6 +67,23 @@ static const char *_skip_fields(const char *p, unsigned nr)
 }
 
 /*
+ * Count number of single-space delimited fields.
+ * Number of fields is number of spaces plus one.
+ */
+static unsigned _count_fields(const char *p)
+{
+	unsigned nr = 1;
+
+	if (!p || !*p)
+		return 0;
+
+	while ((p = _skip_fields(p, 1)))
+		nr++;
+
+	return nr;
+}
+
+/*
  * Various RAID status versions include:
  * Versions < 1.5.0 (4 fields):
  *   <raid_type> <#devs> <health_str> <sync_ratio>
@@ -77,69 +94,71 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		       struct dm_status_raid **status)
 {
 	int i;
-	const char *pp, *p;
-	struct dm_status_raid *s;
+	unsigned num_fields;
+	const char *p, *pp, *msg_fields = "";
+	struct dm_status_raid *s = NULL;
 
-	if (!params || !(p = strchr(params, ' '))) {
-		log_error("Failed to parse invalid raid params.");
-		return 0;
-	}
-	p++;
+	if ((num_fields = _count_fields(params)) < 4)
+		goto_bad;
 
-	/* second field holds the device count */
-	if (sscanf(p, "%d", &i) != 1)
-		return_0;
+	/* Second field holds the device count */
+	msg_fields = "<#devs> ";
+	if (!(p = _skip_fields(params, 1)) || (sscanf(p, "%d", &i) != 1))
+		goto_bad;
 
+	msg_fields = "";
 	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_raid))))
-		return_0;
+		goto_bad;
 
 	if (!(s->raid_type = dm_pool_zalloc(mem, p - params)))
 		goto_bad; /* memory is freed when pool is destroyed */
 
-	if (!(s->dev_health = dm_pool_zalloc(mem, i + 1)))
+	if (!(s->dev_health = dm_pool_zalloc(mem, i + 1))) /* Space for health chars */
 		goto_bad;
 
+	msg_fields = "<raid_type> <#devices> <health_chars> and <sync_ratio> ";
 	if (sscanf(params, "%s %u %s %" PRIu64 "/%" PRIu64,
 		   s->raid_type,
 		   &s->dev_count,
 		   s->dev_health,
 		   &s->insync_regions,
-		   &s->total_regions) != 5) {
-		log_error("Failed to parse raid params: %s", params);
-		goto bad;
-	}
-
-	*status = s;
+		   &s->total_regions) != 5)
+		goto_bad;
 
 	/*
 	 * All pre-1.5.0 version parameters are read.  Now we check
-	 * for additional 1.5.0+ parameters.
+	 * for additional 1.5.0+ parameters (i.e. num_fields at least 6).
 	 *
 	 * Note that 'sync_action' will be NULL (and mismatch_count
 	 * will be 0) if the kernel returns a pre-1.5.0 status.
 	 */
-	for (p = params, i = 0; i < 4; i++, p++)
-		if (!(p = strchr(p, ' ')))
-			return 1;  /* return pre-1.5.0 status */
+	if (num_fields < 6)
+		goto out;
 
-	pp = p;
-	if (!(p = strchr(p, ' '))) {
-		log_error(INTERNAL_ERROR "Bad RAID status received.");
-		goto bad;
-	}
-	p++;
+	msg_fields = "<sync_action> and <mismatch_cnt> ";
 
-	if (!(s->sync_action = dm_pool_zalloc(mem, p - pp)))
+	/* Skip pre-1.5.0 params */
+	if (!(p = _skip_fields(params, 4)) || !(pp = _skip_fields(p, 1)))
 		goto_bad;
 
-	if (sscanf(pp, "%s %" PRIu64, s->sync_action, &s->mismatch_count) != 2) {
-		log_error("Failed to parse raid params: %s", params);
-		goto bad;
-	}
+	if (!(s->sync_action = dm_pool_zalloc(mem, pp - p)))
+		goto_bad;
+
+	if (sscanf(p, "%s %" PRIu64, s->sync_action, &s->mismatch_count) != 2)
+		goto_bad;
+
+out:
+	*status = s;
 
 	return 1;
+
 bad:
-	dm_pool_free(mem, s);
+	log_error("Failed to parse %sraid params: %s", msg_fields, params);
+
+	if (s)
+		dm_pool_free(mem, s);
+
+	*status = NULL;
 
 	return 0;
 }


