From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 09:14:55 +0000 (UTC)
Subject: master - cleanup: use matching const type
Message-ID: <20170213091455.E393B60576@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7cbee8f31ae64c023b294524008885e3a054e394
Commit:        7cbee8f31ae64c023b294524008885e3a054e394
Parent:        b6301aa977df675918f25f6ace11628fa846392c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 18:18:32 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 10:06:18 2017 +0100

cleanup: use matching const type

---
 libdm/libdm-stats.c  |    8 ++++----
 libdm/libdm-string.c |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 8589db3..b74a470 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -402,7 +402,7 @@ static int _stats_bound(const struct dm_stats *dms)
 	if (dms->bind_major > 0 || dms->bind_name || dms->bind_uuid)
 		return 1;
 	/* %p format specifier expects a void pointer. */
-	log_debug("Stats handle at %p is not bound.", (void *) dms);
+	log_debug("Stats handle at %p is not bound.", dms);
 	return 0;
 }
 
@@ -3857,9 +3857,9 @@ struct _extent {
  */
 static int _extent_start_compare(const void *p1, const void *p2)
 {
-	struct _extent *r1, *r2;
-	r1 = (struct _extent *) p1;
-	r2 = (struct _extent *) p2;
+	const struct _extent *r1, *r2;
+	r1 = (const struct _extent *) p1;
+	r2 = (const struct _extent *) p2;
 
 	if (r1->start < r2->start)
 		return -1;
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index d24a474..2085aa8 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -626,7 +626,7 @@ uint64_t dm_units_to_factor(const char *units, char *unit_type,
 	uint64_t multiplier;
 
 	if (endptr)
-		*endptr = (char *) units;
+		*endptr = units;
 
 	if (isdigit(*units)) {
 		custom_value = strtod(units, &ptr);
@@ -709,7 +709,7 @@ uint64_t dm_units_to_factor(const char *units, char *unit_type,
 	}
 
 	if (endptr)
-		*endptr = (char *) units + 1;
+		*endptr = units + 1;
 
 	if (_close_enough(custom_value, 0.))
 		return v * multiplier; /* Use integer arithmetic */


