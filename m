From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:03:55 +0000 (UTC)
Subject: master - libdm: add human R|readable units
Message-ID: <20170120230355.15D4B60D66@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f8234d6e5f4f82690da61abf03f93ddfb5cff467
Commit:        f8234d6e5f4f82690da61abf03f93ddfb5cff467
Parent:        6a20b221516fcecda25bc56996028eb50b3250f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 9 16:30:49 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:52:17 2017 +0100

libdm: add human R|readable units

When showing sizes with 'H|human' units we do use standard rounding.
This however is confusing users from time to time,
when the printed number uses some biger units i.e. GiB and there is just
tiny fraction of space missing.

So here is some real-life example with new 'r' unit.

$lvs

  LV    VG Attr       LSize  Pool Origin
  lvol0 vg -wi-a-----  1.99g
  lvol1 vg -wi-a----- <2.00g
  lvol2 vg -wi-a----- <2.01g

Meaning is - lvol1 has 'slightly' less then 2.00g - from sign '<' user
can be aware the LV doesn't have full 2.00GiB in size so he
will be less surpriced allocation of 2G volume will not succeed.

$ vgs
  VG #PV #LV #SN Attr   VSize  VFree
  vg   2   2   0 wz--n- <6,00g <2,01g

For uses needing  'old'  undecorated human unit simply will continue
to use 'H|h' units.

The new R|r  may further change when we would recongnize some
other way how to improve readability.
---
 WHATS_NEW             |    1 +
 WHATS_NEW_DM          |    1 +
 conf/example.conf.in  |    2 +-
 lib/config/defaults.h |    2 +-
 libdm/libdm-string.c  |   18 ++++++++++++++++--
 5 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 44b1df8..8f0d131 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Use new default units 'r' for displaying sizes.
   Also unmount mount point on top of MD device if using blkdeactivate -u.
   Restore check preventing resize of cache type volumes (2.02.158).
   Add missing udev sync when flushing dirty cache content.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 67aed5e..a8d4105 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Support new R|r human readable units output format.
   Thin dmeventd plugin reacts faster on lvextend failure path with umount.
   Add dm_stats_bind_from_fd() to bind a stats handle from a file descriptor.
   Do not try call callback when reverting activation on error path.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index b1a2a9c..c3defe5 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -665,7 +665,7 @@ global {
 
 	# Configuration option global/units.
 	# Default value for --units argument.
-	units = "h"
+	units = "r"
 
 	# Configuration option global/si_unit_consistency.
 	# Distinguish between powers of 1024 and 1000 bytes.
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index d988779..5479cc5 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -176,7 +176,7 @@
 #define DEFAULT_INDENT 1
 #define DEFAULT_ABORT_ON_INTERNAL_ERRORS 0
 #define DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION 0
-#define DEFAULT_UNITS "h"
+#define DEFAULT_UNITS "r"
 #define DEFAULT_SUFFIX 1
 #define DEFAULT_HOSTTAGS 0
 
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 39117f8..d24a474 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -468,10 +468,12 @@ const char *dm_size_to_string(struct dm_pool *mem, uint64_t size,
 	unsigned base = BASE_UNKNOWN;
 	unsigned s;
 	int precision;
+	double d;
 	uint64_t byte = UINT64_C(0);
 	uint64_t units = UINT64_C(1024);
 	char *size_buf = NULL;
 	char new_unit_type = '\0', unit_type_buf[2];
+	const char *prefix = "";
 	const char * const size_str[][3] = {
 		/* BASE_UNKNOWN */
 		{"         ", "   ", " "},	/* [0] */
@@ -570,7 +572,7 @@ const char *dm_size_to_string(struct dm_pool *mem, uint64_t size,
 		byte = unit_factor;
 	} else {
 		/* Human-readable style */
-		if (unit_type == 'H') {
+		if (unit_type == 'H' || unit_type == 'R') {
 			units = UINT64_C(1000);
 			base = BASE_1000;
 		} else {
@@ -586,6 +588,16 @@ const char *dm_size_to_string(struct dm_pool *mem, uint64_t size,
 		for (s = 0; s < NUM_UNIT_PREFIXES && size < byte; s++)
 			byte /= units;
 
+		if ((s < NUM_UNIT_PREFIXES) &&
+		    ((unit_type == 'R') || (unit_type == 'r'))) {
+			/* When the rounding would cause difference, add '<' prefix
+			 * i.e.  2043M is more then 1.9949G prints <2.00G
+			 * This version is for 2 digits fixed precision */
+			d = 100. * (double) size / byte;
+			if (!_close_enough(floorl(d), nearbyintl(d)))
+				prefix = "<";
+		}
+
 		include_suffix = 1;
 	}
 
@@ -599,7 +611,7 @@ const char *dm_size_to_string(struct dm_pool *mem, uint64_t size,
 		precision = 2;
 	}
 
-	snprintf(size_buf, SIZE_BUF - 1, "%.*f%s", precision,
+	snprintf(size_buf, SIZE_BUF - 1, "%s%.*f%s", prefix, precision,
 		 (double) size / byte, include_suffix ? size_str[base + s][suffix_type] : "");
 
 	return size_buf;
@@ -639,6 +651,8 @@ uint64_t dm_units_to_factor(const char *units, char *unit_type,
 	switch (*units) {
 	case 'h':
 	case 'H':
+	case 'r':
+	case 'R':
 		multiplier = v = UINT64_C(1);
 		*unit_type = *units;
 		break;


