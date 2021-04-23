From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:59 +0000 (GMT)
Subject: main - cov: convert to code that analyzer may better understand
Message-ID: <20210423210559.A88F839450F4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8f85834a330c1b803c130d9f7a33633267fb8d5b
Commit:        8f85834a330c1b803c130d9f7a33633267fb8d5b
Parent:        25b672417e06265c4552184b4ae1f0853bd31732
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 15:06:48 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: convert to code that analyzer may better understand

Switch to code that is problematic to analyzer
---
 lib/device/dev-cache.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index dddf84e4d..d7fa93fd6 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -293,13 +293,13 @@ static int _compare_paths(const char *path0, const char *path1)
 	/* We prefer symlinks - they exist for a reason!
 	 * So we prefer a shorter path before the first symlink in the name.
 	 * FIXME Configuration option to invert this? */
-	while (s0) {
-		s0 = strchr(s0, '/');
-		s1 = strchr(s1, '/');
-		if (s0) {
+	while (s0 && s1) {
+		if ((s0 = strchr(s0, '/')))
 			*s0 = '\0';
+
+		if ((s1 = strchr(s1, '/')))
 			*s1 = '\0';
-		}
+
 		if (lstat(p0, &stat0)) {
 			log_sys_very_verbose("lstat", p0);
 			return 1;
@@ -312,10 +312,10 @@ static int _compare_paths(const char *path0, const char *path1)
 			return 0;
 		if (!S_ISLNK(stat0.st_mode) && S_ISLNK(stat1.st_mode))
 			return 1;
-		if (s0) {
+		if (s0)
 			*s0++ = '/';
+		if (s1)
 			*s1++ = '/';
-		}
 	}
 
 	/* ASCII comparison */


