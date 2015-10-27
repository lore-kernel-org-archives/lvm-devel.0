From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 Oct 2015 10:43:17 +0000 (UTC)
Subject: master - dmeventd: event string parser handles empty field
Message-ID: <20151027104317.41DB06103C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d76bdcdbdf6bef81872e8eef2cce156cfce228f
Commit:        5d76bdcdbdf6bef81872e8eef2cce156cfce228f
Parent:        3b5939bbbb974913db3ff7ac363cc7f1154b894e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 27 11:12:59 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 27 11:42:40 2015 +0100

dmeventd: event string parser handles empty field

Improve event string parser to avoid unneeded alloc+free.

Daemon talk function uses '-' to mark NULL/missing field.
So restore the NULL pointer back on parser.

This should have made old tools like 'dmevent_tool' work again.
As now 'uuid' or 'dso' could become NULL and then be
properly used in _want_registered_device() function.

Since lvm2 always fill these parameters, this change should
have no effect on lvm2.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   50 +++++++++++++++++++++++++++---------------
 2 files changed, 33 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e09ab63..961aec5 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Fix/restore parsing of empty field '-' when processing dmeventd event.
   Enhance dm_tree_node_size_changed() to recognize size reduction.
   Support exit on idle for dmenventd (1 hour).
   Add support to allow unmonitor device from plugin itself.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index d6accbf..42c724b 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -473,34 +473,48 @@ static int _pthread_create_smallstack(pthread_t *t, void *(*fun)(void *), void *
 
 /*
  * Fetch a string off src and duplicate it into *ptr.
- * Pay attention to zero-length strings.
+ * Pay attention to zero-length and 'empty' strings ('-').
  */
 /* FIXME? move to libdevmapper to share with the client lib (need to
    make delimiter a parameter then) */
 static int _fetch_string(char **ptr, char **src, const int delimiter)
 {
-	int ret = 0;
+	int ret = 1;
 	char *p;
 	size_t len;
+	*ptr = NULL; /* Empty field returns NULL pointer */
 
-	if ((p = strchr(*src, delimiter)))
-		*p = 0;
-
-	if ((*ptr = dm_strdup(*src))) {
-		if ((len = strlen(*ptr)))
-			*src += len;
-		else {
-			dm_free(*ptr);
-			*ptr = NULL;
+	if ((*src)[0] == '-') {
+		/* Could be empty field '-', handle without allocation */
+		if ((*src)[1] == '\0') {
+			(*src)++;
+			goto out;
+		} else if ((*src)[1] == delimiter) {
+			(*src) += 2;
+			goto out;
 		}
-
-		(*src)++;
-		ret = 1;
 	}
 
-	if (p)
-		*p = delimiter;
-
+	if ((p = strchr(*src, delimiter))) {
+		if (*src < p) {
+			*p = 0; /* Temporary exit with \0 */
+			if (!(*ptr = dm_strdup(*src))) {
+				log_error("Failed to fetch item %s.", *src);
+				ret = 0; /* Allocation fail */
+			}
+			*p = delimiter;
+			*src = p;
+		}
+		(*src)++; /* Skip delmiter, next field */
+	} else if ((len = strlen(*src))) {
+		/* No delimiter, item ends with '\0' */
+		if (!(*ptr = dm_strdup(*src))) {
+			log_error("Failed to fetch last item %s.", *src);
+			ret = 0; /* Fail */
+		}
+		*src += len + 1;
+	}
+out:
 	return ret;
 }
 


