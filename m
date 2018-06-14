From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 17:23:33 -0400
Subject: master - man-generator: drop macro redefines
Message-ID: <201806142123.w5ELNXe7014844@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52e7270e23858509fd0da419ecbc4e42e22f04ac
Commit:        52e7270e23858509fd0da419ecbc4e42e22f04ac
Parent:        faf3cc8f71a6e727e2124199eef25ff00e954c0f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 23:15:28 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 23:22:42 2018 +0200

man-generator: drop macro redefines

---
 tools/command.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index e1391a1..eefc124 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -51,9 +51,6 @@ do { \
 	printf(fmt "\n", ##args); \
 } while (0)
 
-#define malloc malloc
-#define strdup strdup
-#define free free
 #define dm_snprintf snprintf
 
 static int dm_strncpy(char *dest, const char *src, size_t n)


