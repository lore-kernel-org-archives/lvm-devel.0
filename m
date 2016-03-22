From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Mar 2016 21:41:20 +0000 (UTC)
Subject: master - libdm: Change _advance_to_next_word to _skip_fields
Message-ID: <20160322214121.0246261056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65d2d66d02133fc6df1baba74a7fe0883ed2a6e0
Commit:        65d2d66d02133fc6df1baba74a7fe0883ed2a6e0
Parent:        1216efdf152043bd04e8db170b5b3fb569bef329
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Mar 22 19:26:13 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Mar 22 19:26:13 2016 +0000

libdm: Change _advance_to_next_word to _skip_fields

---
 libdm/libdm-targets.c |   31 +++++++++++++++----------------
 1 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index bd6e5e2..fd74336 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -132,14 +132,13 @@ bad:
 	return 0;
 }
 
-static const char *_advance_to_next_word(const char *str, int count)
+/*
+ * Skip nr fields delimited by a single space.
+ */
+static const char *_skip_fields(const char *p, unsigned nr)
 {
-	int i;
-	const char *p;
-
-	for (p = str, i = 0; i < count; i++, p++)
-		if (!(p = strchr(p, ' ')))
-			return NULL;
+	while (p && nr-- && (p = strchr(p, ' ')))
+		p++;
 
 	return p;
 }
@@ -228,7 +227,7 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 		goto bad;
 
 	/* Now jump to "features" section */
-	if (!(p = _advance_to_next_word(params, 12)))
+	if (!(p = _skip_fields(params, 12)))
 		goto bad;
 
 	/* Read in features */
@@ -240,31 +239,31 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 		else
 			log_error("Unknown feature in status: %s", params);
 
-		if (!(p = _advance_to_next_word(p, 1)))
+		if (!(p = _skip_fields(p, 1)))
 			goto bad;
 	}
 
 	/* Read in core_args. */
 	if (sscanf(p, "%d ", &s->core_argc) != 1)
 		goto bad;
-	if (s->core_argc &&
+	if ((s->core_argc > 0) &&
 	    (!(s->core_argv = dm_pool_zalloc(mem, sizeof(char *) * s->core_argc)) ||
-	     !(p = _advance_to_next_word(p, 1)) ||
+	     !(p = _skip_fields(p, 1)) ||
 	     !(str = dm_pool_strdup(mem, p)) ||
-	     !(p = _advance_to_next_word(p, s->core_argc)) ||
+	     !(p = _skip_fields(p, (unsigned) s->core_argc)) ||
 	     (dm_split_words(str, s->core_argc, 0, s->core_argv) != s->core_argc)))
 		goto bad;
 
 	/* Read in policy args */
 	pp = p;
-	if (!(p = _advance_to_next_word(p, 1)) ||
+	if (!(p = _skip_fields(p, 1)) ||
 	    !(s->policy_name = dm_pool_zalloc(mem, (p - pp))))
 		goto bad;
 	if (sscanf(pp, "%s %d", s->policy_name, &s->policy_argc) != 2)
 		goto bad;
 	if (s->policy_argc &&
 	    (!(s->policy_argv = dm_pool_zalloc(mem, sizeof(char *) * s->policy_argc)) ||
-	     !(p = _advance_to_next_word(p, 1)) ||
+	     !(p = _skip_fields(p, 1)) ||
 	     !(str = dm_pool_strdup(mem, p)) ||
 	     (dm_split_words(str, s->policy_argc, 0, s->policy_argv) != s->policy_argc)))
 		goto bad;
@@ -444,7 +443,7 @@ int dm_get_status_mirror(struct dm_pool *mem, const char *params,
 	for (i = 0; i < num_devs ; ++i)
 		s->devs[i].health = pos[i];
 
-	if (!(pos = _advance_to_next_word(pos, argc)))
+	if (!(pos = _skip_fields(pos, argc)))
 		goto_out;
 
 	if (sscanf(pos, "%u %n", &argc, &used) != 1)
@@ -458,7 +457,7 @@ int dm_get_status_mirror(struct dm_pool *mem, const char *params,
 			goto out;
 		}
 	} else {
-		if (!(p = _advance_to_next_word(pos, 1)))
+		if (!(p = _skip_fields(pos, 1)))
 			goto_out;
 
 		/* disk, cluster-disk */


