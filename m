From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Mar 2016 14:19:15 +0000 (UTC)
Subject: master - cleanup: previous patch with libdm config node buffer size
Message-ID: <20160304141915.611DF61042@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67c5006e12c9e3bf888db0fbaa78a50efcbfa9b2
Commit:        67c5006e12c9e3bf888db0fbaa78a50efcbfa9b2
Parent:        967a0889a024e2cc3f3afb3469e1b0657ebb85bc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 4 15:19:09 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 4 15:19:09 2016 +0100

cleanup: previous patch with libdm config node buffer size

---
 libdm/libdm-config.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index a7f4096..5fa06a1 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -222,7 +222,7 @@ __attribute__ ((format(printf, 2, 3)))
 static int _line_append(struct config_output *out, const char *fmt, ...)
 {
 	char buf[4096];
-	char *final_buf;
+	char *dyn_buf = NULL;
 	va_list ap;
 	int n;
 
@@ -246,21 +246,23 @@ static int _line_append(struct config_output *out, const char *fmt, ...)
 		 * so try dynamically allocated buffer now...
 		 */
 		va_start(ap, fmt);
-		n = dm_vasprintf(&final_buf, fmt, ap);
+		n = dm_vasprintf(&dyn_buf, fmt, ap);
 		va_end(ap);
 
 		if (n < 0) {
 			log_error("dm_vasprintf failed for config line");
 			return 0;
 		}
-	} else
-		final_buf = buf;
+	}
 
-	if (!dm_pool_grow_object(out->mem, final_buf, strlen(final_buf))) {
+	if (!dm_pool_grow_object(out->mem, dyn_buf ? : buf, 0)) {
 		log_error("dm_pool_grow_object failed for config line");
+		dm_free(dyn_buf);
 		return 0;
 	}
 
+	dm_free(dyn_buf);
+
 	return 1;
 }
 


