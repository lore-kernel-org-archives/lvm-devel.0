From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Nov 2011 10:59:07 +0100
Subject: [PATCH 5/7] Minor cleanup of strchr analyzer warning
In-Reply-To: <cover.1322213495.git.zkabelac@redhat.com>
References: <cover.1322213495.git.zkabelac@redhat.com>
Message-ID: <015f152795adfbef2951bae7ecca569e3de29eab.1322213495.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

While the code knows, path0 and path1 has the same amount of '/'
otherwise the shorter path wins - the static analyzer is confused.
So just add extra check also for 's1' strchr to clean away warning
about unchecked strchr().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-cache.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 9b401ee..161bff7 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -264,8 +264,8 @@ static int _compare_paths(const char *path0, const char *path1)
 
 	strncpy(p0, path0, PATH_MAX);
 	strncpy(p1, path1, PATH_MAX);
-	s0 = &p0[0] + 1;
-	s1 = &p1[0] + 1;
+	s0 = p0 + 1;
+	s1 = p1 + 1;
 	while (*s0 && *s0 == *s1)
                 s0++, s1++;
 
@@ -273,12 +273,11 @@ static int _compare_paths(const char *path0, const char *path1)
 	 * So we prefer a shorter path before the first symlink in the name.
 	 * FIXME Configuration option to invert this? */
 	while (s0) {
-		s0 = strchr(s0, '/');
-		s1 = strchr(s1, '/');
-		if (s0) {
+		if ((s0 = strchr(s0, '/')))
 			*s0 = '\0';
+		if ((s1 = strchr(s1, '/')))
 			*s1 = '\0';
-		}
+
 		if (lstat(p0, &stat0)) {
 			log_sys_very_verbose("lstat", p0);
 			return 1;
@@ -291,10 +290,9 @@ static int _compare_paths(const char *path0, const char *path1)
 			return 0;
 		if (!S_ISLNK(stat0.st_mode) && S_ISLNK(stat1.st_mode))
 			return 1;
-		if (s0) {
-			*s0++ = '/';
-			*s1++ = '/';
-		}
+
+		if (s0) *s0++ = '/';
+		if (s1) *s1++ = '/';
 	}
 
 	/* ASCII comparison */
-- 
1.7.7.3


