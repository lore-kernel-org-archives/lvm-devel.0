From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 18 Jul 2013 17:00:51 +0000 (UTC)
Subject: master - display: fix units for sizes <1k
Message-ID: <20130718170051.8356460DF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=357df34133fae754eb25cf3c3a784b1905fc9291
Commit:        357df34133fae754eb25cf3c3a784b1905fc9291
Parent:        ef3a1a0f8a7dc9656fa9269f08b36d1a9cb96d91
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 18 17:55:58 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 18 17:55:58 2013 +0100

display: fix units for sizes <1k

---
 WHATS_NEW             |    1 +
 lib/display/display.c |   40 +++++++++++++++++++++-------------------
 2 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e87f781..9102613 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Use units B or b (never E) with no decimal places when displaying sizes < 1k.
   Add support for poolmetadataspare LV, that will be used for pool recovery.
   Improve activation order when creating thin pools in non-clustered VG.
   List thin-pool and thin modules for thin volumes.
diff --git a/lib/display/display.c b/lib/display/display.c
index 3f7f360..bf4b642 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -176,9 +176,9 @@ alloc_policy_t get_alloc_from_string(const char *str)
 
 #define BASE_UNKNOWN 0
 #define BASE_SHARED 1
-#define BASE_1024 7
-#define BASE_1000 13
-#define BASE_SPECIAL 19
+#define BASE_1024 8
+#define BASE_1000 15
+#define BASE_SPECIAL 21
 #define NUM_UNIT_PREFIXES 6
 #define NUM_SPECIAL 3
 
@@ -203,27 +203,29 @@ static const char *_display_size(const struct cmd_context *cmd,
 		{" Gigabyte", " GB", "G"},	/* [4] */
 		{" Megabyte", " MB", "M"},	/* [5] */
 		{" Kilobyte", " KB", "K"},	/* [6] */
+		{" Byte    ", " B", "B"},	/* [7] */
 
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
+		{" Byte    ", " B", "b"},	/* [14] */
 
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
 
 		/* BASE_SPECIAL */
-		{" Byte    ", " B ", "B"},	/* [19] */
-		{" Units   ", " Un", "U"},	/* [20] */
-		{" Sectors ", " Se", "S"},	/* [21] */
+		{" Byte    ", " B ", "B"},	/* [21] (shared with BASE_1000) */
+		{" Units   ", " Un", "U"},	/* [22] */
+		{" Sectors ", " Se", "S"},	/* [23] */
 	};
 
 	if (!(size_buf = dm_pool_alloc(cmd->mem, SIZE_BUF))) {
@@ -302,7 +304,7 @@ static const char *_display_size(const struct cmd_context *cmd,
 	}
 
 	/* FIXME Make precision configurable */
-	switch(toupper((int) cmd->current_settings.unit_type)) {
+	switch (toupper(*size_str[base + s][SIZE_UNIT])) {
 	case 'B':
 	case 'S':
 		precision = 0;


