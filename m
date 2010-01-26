From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 26 Jan 2010 16:49:05 -0500
Subject: [PATCH] Fix display of units < 1k.
Message-ID: <1264542545-13119-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Saw this problem while testing metadata area related changes
(I filled up metadata until pv_mda_free was < 1k).
A display of a 'size' that was 512 bytes will display as
"512E" because of overflow of the arrays.  Simple fix is to
just duplicate the 'byte' array values for all the 'BASE'
types.  Not sure if there are any other fields where this
can occur - maybe not.

Original display of 512 bytes:
  VG           PV         1st PE  #PMda PMdaFree  PMdaSize  VMdaFree
  vgtest       /dev/loop0 192.00k     1    64.50k   188.00k   512.00E
  vgtest       /dev/loop1 192.00k     1    64.50k   188.00k   512.00E
  vgtest       /dev/loop2 192.00k     1    64.50k   188.00k   512.00E
  vgtest       /dev/loop3  64.00k     1   512.00E    60.00k   512.00E

New display of 512 bytes:
  VG           PV         1st PE  #PMda PMdaFree  PMdaSize  VMdaFree
  vgtest       /dev/loop0 192.00k     1    64.50k   188.00k   512.00B
  vgtest       /dev/loop1 192.00k     1    64.50k   188.00k   512.00B
  vgtest       /dev/loop2 192.00k     1    64.50k   188.00k   512.00B
  vgtest       /dev/loop3  64.00k     1   512.00B    60.00k   512.00B

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/display/display.c |   41 ++++++++++++++++++++++-------------------
 1 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index a835327..1836d6c 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -149,10 +149,10 @@ alloc_policy_t get_alloc_from_string(const char *str)
 
 #define BASE_UNKNOWN 0
 #define BASE_SHARED 1
-#define BASE_1024 7
-#define BASE_1000 13
-#define BASE_SPECIAL 19
-#define NUM_UNIT_PREFIXES 6
+#define BASE_1024 8
+#define BASE_1000 15
+#define BASE_SPECIAL 22
+#define NUM_UNIT_PREFIXES 7
 #define NUM_SPECIAL 3
 
 /* Size supplied in sectors */
@@ -176,27 +176,30 @@ static const char *_display_size(const struct cmd_context *cmd,
 		{" Gigabyte", " GB", "G"},	/* [4] */
 		{" Megabyte", " MB", "M"},	/* [5] */
 		{" Kilobyte", " KB", "K"},	/* [6] */
+		{" Byte    ", " B ", "B"},	/* [7] */
 
 		/* BASE_1024 - Used if cmd->si_unit_consistency = 1 */
-		{" Exbibyte", " EiB", "e"},	/* [7] */
-		{" Pebibyte", " PiB", "p"},	/* [8] */
-		{" Tebibyte", " TiB", "t"},	/* [9] */
-		{" Gibibyte", " GiB", "g"},	/* [10] */
-		{" Mebibyte", " MiB", "m"},	/* [11] */
-		{" Kibibyte", " KiB", "k"},	/* [12] */
+		{" Exbibyte", " EiB", "e"},	/* [8] */
+		{" Pebibyte", " PiB", "p"},	/* [9] */
+		{" Tebibyte", " TiB", "t"},	/* [10] */
+		{" Gibibyte", " GiB", "g"},	/* [11] */
+		{" Mebibyte", " MiB", "m"},	/* [12] */
+		{" Kibibyte", " KiB", "k"},	/* [13] */
+		{" Byte    ", " B ", "B"},	/* [14] */
 
 		/* BASE_1000 - Used if cmd->si_unit_consistency = 1 */
-		{" Exabyte",  " EB", "E"},	/* [13] */
-		{" Petabyte", " PB", "P"},	/* [14] */
-		{" Terabyte", " TB", "T"},	/* [15] */
-		{" Gigabyte", " GB", "G"},	/* [16] */
-		{" Megabyte", " MB", "M"},	/* [17] */
-		{" Kilobyte", " kB", "K"},	/* [18] */
+		{" Exabyte",  " EB", "E"},	/* [15] */
+		{" Petabyte", " PB", "P"},	/* [16] */
+		{" Terabyte", " TB", "T"},	/* [17] */
+		{" Gigabyte", " GB", "G"},	/* [18] */
+		{" Megabyte", " MB", "M"},	/* [19] */
+		{" Kilobyte", " kB", "K"},	/* [20] */
+		{" Byte    ", " B ", "B"},	/* [21] */
 
 		/* BASE_SPECIAL */
-		{" Byte    ", " B ", "B"},	/* [19] */
-		{" Units   ", " Un", "U"},	/* [20] */
-		{" Sectors ", " Se", "S"},	/* [21] */
+		{" Byte    ", " B ", "B"},	/* [22] */
+		{" Units   ", " Un", "U"},	/* [23] */
+		{" Sectors ", " Se", "S"},	/* [24] */
 	};
 
 	if (!(size_buf = dm_pool_alloc(cmd->mem, SIZE_BUF))) {
-- 
1.6.0.6


