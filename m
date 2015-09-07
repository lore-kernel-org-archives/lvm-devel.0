From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  7 Sep 2015 10:46:52 +0000 (UTC)
Subject: master - libdm: add missing error handling in _stats_parse_histogram()
Message-ID: <20150907104652.4F6DF61255@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36b09fd1471ecbae84b22075b46fada2bd8761ee
Commit:        36b09fd1471ecbae84b22075b46fada2bd8761ee
Parent:        a26523330e8f461b90eca7d2dcea0d0a6866e635
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 7 11:44:53 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 7 11:44:53 2015 +0100

libdm: add missing error handling in _stats_parse_histogram()

Since we are growing an object in the histogram pool the return
value of dm_pool_grow_object() must be checked and error paths need
to abandon the object before returning.
---
 libdm/libdm-stats.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 93c7760..5616370 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -721,22 +721,20 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 
 	hist.nr_bins = nr_bins;
 
-	dm_pool_grow_object(mem, &hist, sizeof(hist));
+	if (!dm_pool_grow_object(mem, &hist, sizeof(hist)))
+		goto_bad;
 
 	do {
 		memset(&cur, 0, sizeof(cur));
 		for (v = _valid_chars; *v; v++)
 			if (*c == *v)
 				break;
-		if (!*v) {
-			stack;
+		if (!*v)
 			goto badchar;
-		}
 
-		if (*c == ',') {
-			log_error("Invalid histogram: %s", hist_str);
-			return 0;
-		} else {
+		if (*c == ',')
+			goto badchar;
+		else {
 			const char *val_start = c;
 			char *endptr = NULL;
 			uint64_t this_val = 0;
@@ -744,17 +742,15 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 			this_val = strtoull(val_start, &endptr, 10);
 			if (!endptr) {
 				log_error("Could not parse histogram value.");
-				return 0;
+				goto bad;
 			}
 			c = endptr; /* Advance to colon, or end. */
 
 			if (*c == ':')
 				c++;
-			else if (*c & (*c != '\n')) {
+			else if (*c & (*c != '\n'))
 				/* Expected ':', '\n', or NULL. */
-				stack;
 				goto badchar;
-			}
 
 			if (*c == ':')
 				c++;
@@ -763,7 +759,8 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 			cur.count = this_val;
 			sum += this_val;
 
-			dm_pool_grow_object(mem, &cur, sizeof(cur));
+			if (!dm_pool_grow_object(mem, &cur, sizeof(cur)))
+				goto_bad;
 
 			bin++;
 		}
@@ -778,6 +775,8 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 
 badchar:
 	log_error("Invalid character in histogram data: '%c' (0x%x)", *c, *c);
+bad:
+	dm_pool_abandon_object(mem);
 	return 0;
 }
 


