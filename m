From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 29 May 2017 08:55:32 -0400
Subject: master - cleanup: backtrace
Message-ID: <201705291255.v4TCtWd5002359@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bb0c5197f00594e50fb2b8a92f96633f32a9817
Commit:        1bb0c5197f00594e50fb2b8a92f96633f32a9817
Parent:        966d1130dbf1e9da5ae0b432296741ba4ad35b6a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 29 12:43:07 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 29 14:48:33 2017 +0200

cleanup: backtrace

Add debug backtrace.
---
 lib/format_text/flags.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 4e49963..871eeab 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -132,7 +132,7 @@ int print_flags(char *buffer, size_t size, enum pv_vg_lv_e type, int mask, uint6
 		return_0;
 
 	if (!emit_to_buffer(&buffer, &size, "["))
-		return 0;
+		return_0;
 
 	for (f = 0; flags[f].mask; f++) {
 		if (status & flags[f].mask) {
@@ -147,18 +147,18 @@ int print_flags(char *buffer, size_t size, enum pv_vg_lv_e type, int mask, uint6
 
 			if (!first) {
 				if (!emit_to_buffer(&buffer, &size, ", "))
-					return 0;
+					return_0;
 			} else
 				first = 0;
 	
 			if (!emit_to_buffer(&buffer, &size, "\"%s\"",
-			    flags[f].description))
-				return 0;
+					    flags[f].description))
+				return_0;
 		}
 	}
 
 	if (!emit_to_buffer(&buffer, &size, "]"))
-		return 0;
+		return_0;
 
 	if (status)
 		log_warn(INTERNAL_ERROR "Metadata inconsistency: "


