From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:05 -0500
Subject: master - coverity: avoid memleak
Message-ID: <201711072036.vA7Ka5QI007666@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=56b527a6fbf6f886af4c78dd118867e4513c6a9c
Commit:        56b527a6fbf6f886af4c78dd118867e4513c6a9c
Parent:        14d0b0bbddb214fbb5dcacfb60d1723d87076bd9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 5 18:39:05 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:26:09 2017 +0100

coverity: avoid memleak

When security_level was set, allocated filename was leaking.
---
 WHATS_NEW           |    1 +
 tools/vgcfgbackup.c |   13 +++++++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 94a7af6..0775d7b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Fix memleak of string buffer when vgcfgbackup runs in secure mode.
   Do not print error when clvmd cannot find running clvmd.
   Prevent start of new merge of snapshot if origin is already being merged.
 
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 5d21131..814ed1d 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -20,8 +20,13 @@ static char *_expand_filename(const char *template, const char *vg_name,
 {
 	char *filename;
 
-	if (security_level())
-		return dm_strdup(template);
+	if (security_level()) {
+		if (!(filename = dm_strdup(template))) {
+			log_error("Failed to allocate filename.");
+			return NULL;
+		}
+		goto out;
+	}
 
 	if (!(filename = dm_malloc(PATH_MAX))) {
 		log_error("Failed to allocate filename.");
@@ -31,7 +36,7 @@ static char *_expand_filename(const char *template, const char *vg_name,
 	if (dm_snprintf(filename, PATH_MAX, template, vg_name) < 0) {
 		log_error("Error processing filename template %s",
 			   template);
-		dm_free(filename);	
+		dm_free(filename);
 		return NULL;
 	}
 	if (*last_filename && !strncmp(*last_filename, filename, PATH_MAX)) {
@@ -40,7 +45,7 @@ static char *_expand_filename(const char *template, const char *vg_name,
 		dm_free(filename);
 		return NULL;
 	}
-
+out:
 	dm_free(*last_filename);
 	*last_filename = filename;
 


