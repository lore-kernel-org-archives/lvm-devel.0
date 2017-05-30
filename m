From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 30 May 2017 12:44:47 -0400
Subject: master - flags: improve unknown flags logic
Message-ID: <201705301644.v4UGileD014280@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fb86bddda2e2944699d9c0705a16642ed1dc99b5
Commit:        fb86bddda2e2944699d9c0705a16642ed1dc99b5
Parent:        d1ac6108c39ff8a3496624508a0e709c503d7d9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 30 15:59:42 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue May 30 18:43:45 2017 +0200

flags: improve unknown flags logic

Use same logic as with unknown segment type - so preserve such
name fully with all flags just with UNKNOWN segment type bits.
---
 lib/format_text/flags.c |   34 ++++++++++++++++++++++------------
 1 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 2b934da..d86ceb7 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -229,16 +229,22 @@ int read_segtype_lvflags(uint64_t *status, char *segtype_str)
 	unsigned i;
 	const struct flag *flags = _lv_flags;
 	char *delim;
-	char *flag;
+	char *flag, *buffer, *str;
 
-	if (!(delim = strchr(segtype_str, '+')))
+	if (!(str = strchr(segtype_str, '+')))
 		return 1; /* No flags */
 
-	*delim = '\0'; /* Cut away 1st. '+' */
+	if (!(buffer = dm_strdup(str + 1))) {
+		log_error("Cannot duplicate segment string.");
+		return 0;
+	}
+
+	delim = buffer;
+
 	do {
-		flag = delim + 1;
-		if ((delim = strchr(segtype_str, '+')))
-			*delim = '\0';
+		flag = delim;
+		if ((delim = strchr(delim, '+')))
+			*delim++ = '\0';
 
 		for (i = 0; flags[i].description; i++)
 			if ((flags[i].kind & SEGTYPE_FLAG) &&
@@ -247,12 +253,16 @@ int read_segtype_lvflags(uint64_t *status, char *segtype_str)
 				break;
 			}
 
-		if (!flags[i].description) {
-			log_error("Unknown flag %s passed with segment type %s.",
-				  flag, segtype_str);
-			return 0; /* Unknown flag is incompatible */
-		}
-	} while (delim); /* Till no more flags in type appear */
+	} while (delim && flags[i].description); /* Till no more flags in type appear */
+
+	if (!flags[i].description)
+		/* Unknown flag is incompatible - returns unmodified segtype_str */
+		log_warn("WARNING: Unrecognised flag %s in segment type %s.",
+			 flag, segtype_str);
+	else
+		*str = '\0'; /* Cut away 1st. '+' */
+
+	dm_free(buffer);
 
 	return 1;
 }


