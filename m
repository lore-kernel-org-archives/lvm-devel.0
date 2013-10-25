From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 25 Oct 2013 08:45:05 +0000 (UTC)
Subject: master - gcc: fix comparing floating point warning
Message-ID: <20131025084505.DCDE76005D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e1f2e733ecb191a1dda149ac42e2570142a1d97
Commit:        8e1f2e733ecb191a1dda149ac42e2570142a1d97
Parent:        d4e5140b5284cac151d06615328dc8af21dc15c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 25 10:38:09 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 25 10:43:32 2013 +0200

gcc: fix comparing floating point warning

Since we enabled some more gcc warnings - let's adapt for
it and check for double equals with DBL_EPSILON.

Current close_enough() is far from perfect
for more details see i.e. here:
http://randomascii.wordpress.com/2012/01/11/tricks-with-the-floating-point-format/
but fairly enough for lvm2 use-case.
---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |   11 ++++++++++-
 lib/display/display.c          |   16 ++++++++++++----
 3 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cb3488b..b17fa42 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104 -
 ===================================
+  Compare equality of double values with DBL_EPSILON predefined constant.
   Use additional gcc warning flags by default.
   Add ignore_lvm_mirrors to config file to read/ignore labels on mirrors.
   Add internal flag for temporary LVs to properly direct udev to not interfere.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 285c8cc..03d89c9 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -26,6 +26,9 @@
 #include <stdint.h>
 #include <unistd.h>
 
+#include <math.h>  /* fabs() */
+#include <float.h> /* DBL_EPSILON */
+
 typedef struct {
 	log_state *log; /* convenience */
 	const char *log_config;
@@ -503,6 +506,12 @@ bad:
 	return reply_fail("out of memory");
 }
 
+/* Test if the doubles are close enough to be considered equal */
+static int close_enough(double d1, double d2)
+{
+	return fabs(d1 - d2) < DBL_EPSILON;
+}
+
 static int compare_value(struct dm_config_value *a, struct dm_config_value *b)
 {
 	int r = 0;
@@ -514,7 +523,7 @@ static int compare_value(struct dm_config_value *a, struct dm_config_value *b)
 
 	switch (a->type) {
 	case DM_CFG_STRING: r = strcmp(a->v.str, b->v.str); break;
-	case DM_CFG_FLOAT: r = (a->v.f == b->v.f) ? 0 : (a->v.f > b->v.f) ? 1 : -1; break;
+	case DM_CFG_FLOAT: r = close_enough(a->v.f, b->v.f) ? 0 : (a->v.f > b->v.f) ? 1 : -1; break;
 	case DM_CFG_INT: r = (a->v.i == b->v.i) ? 0 : (a->v.i > b->v.i) ? 1 : -1; break;
 	case DM_CFG_EMPTY_ARRAY: return 0;
 	}
diff --git a/lib/display/display.c b/lib/display/display.c
index bf4b642..d3b4d6e 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -20,6 +20,8 @@
 #include "toolcontext.h"
 #include "segtype.h"
 #include "defaults.h"
+#include <math.h>  /* fabs() */
+#include <float.h> /* DBL_EPSILON */
 
 #define SIZE_BUF 128
 
@@ -41,6 +43,12 @@ static const struct {
 
 static const int _num_policies = sizeof(_policies) / sizeof(*_policies);
 
+/* Test if the doubles are close enough to be considered equal */
+static int _close_enough(double d1, double d2)
+{
+	return fabs(d1 - d2) < DBL_EPSILON;
+}
+
 uint64_t units_to_bytes(const char *units, char *unit_type)
 {
 	char *ptr = NULL;
@@ -53,7 +61,7 @@ uint64_t units_to_bytes(const char *units, char *unit_type)
 		if (ptr == units)
 			return 0;
 		v = (uint64_t) strtoull(units, NULL, 10);
-		if ((double) v == custom_value)
+		if (_close_enough((double) v, custom_value))
 			custom_value = 0;	/* Use integer arithmetic */
 		units = ptr;
 	} else
@@ -126,10 +134,10 @@ uint64_t units_to_bytes(const char *units, char *unit_type)
 		return 0;
 	}
 
-	if (custom_value)
-		return (uint64_t) (custom_value * multiplier);
+	if (_close_enough(custom_value, 0.))
+		return v * multiplier; /* Use integer arithmetic */
 	else
-		return v * multiplier;
+		return (uint64_t) (custom_value * multiplier);
 }
 
 char alloc_policy_char(alloc_policy_t alloc)


