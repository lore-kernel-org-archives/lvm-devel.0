From: Daniel Mierswa <impulze@impulze.org>
Date: Sat, 26 Sep 2009 17:33:46 +0200
Subject: [PATCH 2/3] differentiate between S.I. and binary units in output
In-Reply-To: <1253979227-28051-1-git-send-email-impulze@impulze.org>
References: <1253979227-28051-1-git-send-email-impulze@impulze.org>
Message-ID: <1253979227-28051-2-git-send-email-impulze@impulze.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Current behaviour would print identical strings for S.I. and binary
based units, say KB or Megabyte, also K/M/G in short notation.
This can be confusing at times, because the manual for lvs/pvs/vgs etc.
all state that you pass lowercase suffixes for binary and uppercase
suffixes for S.I. suffixes.
This patch attempts to differentiate between those units in the output
and print a proper string accordingly.
For binary based uints:
 Long output strings (unsed) will be Kibibyte, Mebibyte, etc.
 Short output strings will be KiB, MiB, etc.
 Unit output strings will be lower-cased: k, m, g, etc.
 Sectors determined by division with 512 will be suffixed with s.
For S.I. based units:
 Long output strings (unused) will be Kilobyte, Megabyte, etc.
 Short output strings will be kB, MB, GB, etc.
 Unit output strings will be upper-cased: K, M, G, etc.
 Sectors determined by division with 500 will be suffixed with S.

This will break every script that relies on the output of commands,
which would print "KB", "MB", etc.
They need to be adjusted to respect above documented notions and also
take into consideration that padding changed, i.e. " MB" = " MB ", since
" MiB" and so forth have 3 letters. See the patch for details.

Signed-off-by: Daniel Mierswa <impulze@impulze.org>
---
 lib/display/display.c |   54 ++++++++++++++++++++++++++++++++----------------
 1 files changed, 36 insertions(+), 18 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index b8da95b..1be7366 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -156,20 +156,30 @@ static const char *_display_size(const struct cmd_context *cmd,
 	int s;
 	int suffix = 1, precision;
 	uint64_t byte = UINT64_C(0);
-	uint64_t units = UINT64_C(1024);
 	char *size_buf = NULL;
 	const char * const size_str[][3] = {
-		{" Exabyte", " EB", "E"},
-		{" Petabyte", " PB", "P"},
-		{" Terabyte", " TB", "T"},
-		{" Gigabyte", " GB", "G"},
-		{" Megabyte", " MB", "M"},
-		{" Kilobyte", " KB", "K"},
+		{" Exbibyte", " EiB", "e"},
+		{" Pebibyte", " PiB", "p"},
+		{" Tebibyte", " TiB", "t"},
+		{" Gibibyte", " GiB", "g"},
+		{" Mebibyte", " MiB", "m"},
+		{" Kibibyte", " KiB", "k"},
+		{" Sectors ", " Se ", "s"},
+
+		{" Exabyte ", " EB ", "E"},
+		{" Petabyte", " PB ", "P"},
+		{" Terabyte", " TB ", "T"},
+		{" Gigabyte", " GB ", "G"},
+		{" Megabyte", " MB ", "M"},
+		{" Kilobyte", " kB ", "K"},
+		{" Sectors ", " Se ", "S"},
+
 		{"", "", ""},
-		{" Byte    ", " B ", "B"},
-		{" Units   ", " Un", "U"},
-		{" Sectors ", " Se", "S"},
-		{"         ", "   ", " "},
+
+		{" Byte    ", " B  ", "B"},
+		{" Units   ", " Un ", "U"},
+
+		{"         ", "    ", " "},
 	};
 
 	if (!(size_buf = dm_pool_alloc(cmd->mem, SIZE_BUF))) {
@@ -179,9 +189,14 @@ static const char *_display_size(const struct cmd_context *cmd,
 
 	suffix = cmd->current_settings.suffix;
 
-	for (s = 0; s < 10; s++)
-		if (toupper((int) cmd->current_settings.unit_type) ==
-		    *size_str[s][2])
+	/* find one of kmgtpesKMGTPES */
+	for (s = 0; s < 14; s++)
+		if (cmd->current_settings.unit_type == *size_str[s][2])
+			break;
+
+	/* find one of bBuU */
+	for (; s >= 14 && s < 17; s++)
+		if (toupper((int) cmd->current_settings.unit_type) == *size_str[s][2])
 			break;
 
 	if (size == UINT64_C(0)) {
@@ -191,16 +206,19 @@ static const char *_display_size(const struct cmd_context *cmd,
 
 	size *= UINT64_C(512);
 
-	if (s < 10)
+	if (s < 17)
 		byte = cmd->current_settings.unit_factor;
 	else {
+		uint64_t units;
 		suffix = 1;
-		if (cmd->current_settings.unit_type == 'H')
+		if (cmd->current_settings.unit_type == 'H') {
+			s = 6;
 			units = UINT64_C(1000);
-		else
+		} else {
+			s = 0;
 			units = UINT64_C(1024);
+		}
 		byte = units * units * units * units * units * units;
-		s = 0;
 		while (size_str[s] && size < byte)
 			s++, byte /= units;
 	}
-- 
1.6.4.4


