From: Milan Broz <mbroz@redhat.com>
Date: Wed,  6 Jan 2010 13:20:52 +0100
Subject: [PATCH] Use static buffer to prevent stack overflow in persistent filter dump.
Message-ID: <1262780452-27329-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/filters/filter-persistent.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index d91ed13..9243a94 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -143,7 +143,7 @@ static void _write_array(struct pfilter *pf, FILE *fp, const char *path,
 {
 	void *d;
 	int first = 1;
-	char *buf, *str;
+	char buf[2 * PATH_MAX];
 	struct dm_hash_node *n;
 
 	for (n = dm_hash_get_first(pf->devices); n;
@@ -160,13 +160,8 @@ static void _write_array(struct pfilter *pf, FILE *fp, const char *path,
 			first = 0;
 		}
 
-		str = dm_hash_get_key(pf->devices, n);
-		if (!(buf = alloca(escaped_len(str)))) {
-			log_error("persistent filter device path stack "
-				  "allocation failed");
-			return;
-		}
-		fprintf(fp, "\t\t\"%s\"", escape_double_quotes(buf, str));
+		escape_double_quotes(buf, dm_hash_get_key(pf->devices, n));
+		fprintf(fp, "\t\t\"%s\"", buf);
 	}
 
 	if (!first)
-- 
1.6.5.7


