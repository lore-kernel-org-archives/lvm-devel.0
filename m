From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 21:37:06 +0000 (GMT)
Subject: main - archiving: update refactoring
Message-ID: <20211014213706.4AC6E3858427@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e346ee2a5cd520fc038dda7451360bbe67e629f
Commit:        7e346ee2a5cd520fc038dda7451360bbe67e629f
Parent:        c38473548e546c8e94d41587714f350a11362c84
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 23:31:21 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 14 23:33:26 2021 +0200

archiving: update refactoring

Commit 5ea426e65628218569ede461312d80ba5d1c50fb handled case with
file path without '/' incorrectly - there is valid use-case so
switch 'log_error()' to valid code branch.
---
 lib/format_text/archive.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 740129df0..c9c4f2265 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -373,21 +373,21 @@ int archive_list_file(struct cmd_context *cmd, const char *file)
 	}
 
 	if (!(af.name = strrchr(file, '/'))) {
-		log_error("No '/' in file path %s found.", file);
-		return 0;
-	}
+		af.name = file;
+		path[0] = 0;
+	} else {
+		len = (size_t)(af.name - file);
 
-	len = (size_t)(af.name - file);
+		if (len >= sizeof(path)) {
+			log_error(INTERNAL_ERROR "Passed file path name %s is too long.", file);
+			return 0;
+		}
 
-	if (len >= sizeof(path)) {
-		log_error(INTERNAL_ERROR "Passed file path name %s is too long.", file);
-		return 0;
+		memcpy(path, file, len);
+		path[len] = 0;
+		af.name++;  /* jump over '/' */
 	}
 
-	memcpy(path, file, len);
-	path[len] = 0;
-	af.name++;  /* jump over '/' */
-
 	_display_archive(cmd, path, &af);
 
 	return 1;


