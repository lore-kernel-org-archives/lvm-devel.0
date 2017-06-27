From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jun 2017 06:20:08 -0400
Subject: master - coverity: check malloc results
Message-ID: <201706271020.v5RAK8Sf003888@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e790702f12ddcb730f8dc43d3fdccf08e62aa45
Commit:        8e790702f12ddcb730f8dc43d3fdccf08e62aa45
Parent:        e907535ab977ea29319aeb015cec6c06729f7ce4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 27 10:18:00 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 12:15:42 2017 +0200

coverity: check malloc results

---
 tools/command.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index a08d068..b8b38ad 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -743,7 +743,11 @@ static void add_oo_definition_line(const char *name, const char *line)
 	char *start;
 
 	oo = &oo_lines[oo_line_count++];
-	oo->name = dm_strdup(name);
+
+	if (!(oo->name = dm_strdup(name))) {
+		log_error("Failer to duplicate name %s.", name);
+		return; /* FIXME: return code */
+	}
 
 	if ((colon = strchr(oo->name, ':')))
 		*colon = '\0';
@@ -753,7 +757,10 @@ static void add_oo_definition_line(const char *name, const char *line)
 	}
 
 	start = strchr(line, ':') + 2;
-	oo->line = dm_strdup(start);
+	if (!(oo->line = dm_strdup(start))) {
+		log_error("Failer to duplicate line %s.", start);
+		return;
+	}
 }
 
 /* Support OO_FOO: continuing on multiple lines. */


