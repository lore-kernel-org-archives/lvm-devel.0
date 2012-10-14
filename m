From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 14 Oct 2012 21:21:25 +0000 (UTC)
Subject: master - cleanup: readable test to check for 32bit overflow
Message-ID: <20121014212125.0EF2222FD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9bb210192dd5b60582633079d4769a582ac11074
Commit:        9bb210192dd5b60582633079d4769a582ac11074
Parent:        3972bd98fbec1c2ab9453a33790636a632e7be65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 19 22:28:06 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 14 23:19:27 2012 +0200

cleanup: readable test to check for 32bit overflow

also swap return value 0 - fail, 1 - success.
---
 tools/toollib.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 1916bfd..3fe1c14 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -994,10 +994,11 @@ static int xstrtouint32(const char *s, char **p, int base, uint32_t *result)
 
 	errno = 0;
 	ul = strtoul(s, p, base);
-	if (errno || *p == s || (uint32_t) ul != ul)
-		return -1;
+	if (errno || *p == s || ul > UINT32_MAX)
+		return 0;
 	*result = ul;
-	return 0;
+
+	return 1;
 }
 
 static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
@@ -1029,7 +1030,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 
 		/* Start extent given? */
 		if (isdigit(*c)) {
-			if (xstrtouint32(c, &endptr, 10, &start))
+			if (!xstrtouint32(c, &endptr, 10, &start))
 				goto error;
 			c = endptr;
 			/* Just one number given? */
@@ -1040,7 +1041,7 @@ static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
 		if (*c == '-') {
 			c++;
 			if (isdigit(*c)) {
-				if (xstrtouint32(c, &endptr, 10, &end))
+				if (!xstrtouint32(c, &endptr, 10, &end))
 					goto error;
 				c = endptr;
 			}


