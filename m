From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:23 +0000 (UTC)
Subject: dev-mornfall-activate - libdm: add public macro DM_TO_STRING
Message-ID: <20130604192723.77A5E61182@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5c452a137ba36840d71f3bde23b1a6b496ede4f
Commit:        c5c452a137ba36840d71f3bde23b1a6b496ede4f
Parent:        2f1a571c9707d596d7716cec9488e54ba4c0c946
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 12:46:21 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 16:53:59 2013 +0200

libdm: add public macro DM_TO_STRING

Since this stringifying macro is usable in more places,
move it to the public header with DM_ prefix.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    4 ++++
 libdm/libdm-common.c |    8 ++------
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4a2947a..46ce9b0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Add DM_TO_STRING public macro.
   Always return success on dmeventd -V command call.
   Fix parsing of 64bit snapshot status in dmeventd snapshot plugin.
   Add dm_get_status_snapshot() for parsing snapshot status.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 1bf5807..dba8548 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -34,6 +34,10 @@
 # define __typeof__ typeof
 #endif
 
+/* Macros to make string defines */
+#define DM_TO_STRING_EXP(A) #A
+#define DM_TO_STRING(A) DM_TO_STRING_EXP(A)
+
 #ifdef __cplusplus
 extern "C" {
 #endif
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 4b0ba08..d18de9c 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1591,10 +1591,6 @@ static void _unmangle_mountinfo_string(const char *src, char *buf)
 	*buf = '\0';
 }
 
-/* Macros to make string defines */
-#define TO_STRING_EXP(A) #A
-#define TO_STRING(A) TO_STRING_EXP(A)
-
 /* Parse one line of mountinfo and unmangled target line */
 static int _mountinfo_parse_line(const char *line, unsigned *maj, unsigned *min, char *buf)
 {
@@ -1602,8 +1598,8 @@ static int _mountinfo_parse_line(const char *line, unsigned *maj, unsigned *min,
 	char target[PATH_MAX + 1];
 
 	/* TODO: maybe detect availability of  %ms  glib support ? */
-	if (sscanf(line, "%*u %*u %u:%u %" TO_STRING(PATH_MAX)
-		   "s %" TO_STRING(PATH_MAX) "s",
+	if (sscanf(line, "%*u %*u %u:%u %" DM_TO_STRING(PATH_MAX)
+		   "s %" DM_TO_STRING(PATH_MAX) "s",
 		   maj, min, root, target) < 4) {
 		log_error("Failed to parse mountinfo line.");
 		return 0;


