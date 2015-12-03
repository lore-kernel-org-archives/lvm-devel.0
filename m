From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Dec 2015 17:22:18 +0000 (UTC)
Subject: master - uuid: add id_read_format_try
Message-ID: <20151203172218.8A86961136@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c15c44a4924e07d96cea04672fbcd45c7d8aa7ab
Commit:        c15c44a4924e07d96cea04672fbcd45c7d8aa7ab
Parent:        aec58c862064e2b9dd5b0ebb54473340ebd97f7f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 3 15:25:09 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 3 18:00:38 2015 +0100

uuid: add id_read_format_try

Provide id_read_format() functionality without log_error
when ID is not valid one - it will just return 0.

Does not need to use log_suppress() then.
---
 WHATS_NEW       |    1 +
 lib/uuid/uuid.c |   33 ++++++++++++++++++++++++++-------
 lib/uuid/uuid.h |    4 ++++
 3 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d9222bc..7ade066 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.137 -
 =====================================
+  Added internal id_read_format_try() function to check and read valid UUID.
   Use dm_get_status_mirror() instead of individual parsers.
   Add mem pool arg for check_transient_status() target function.
   Avoid misleading error with -m is omitted with lvconvert to raid types.
diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index 67162dd..cfc58b0 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -132,7 +132,7 @@ static void _build_inverse(void)
 		_inverse_c[(int) *ptr] = (char) 0x1;
 }
 
-int id_valid(struct id *id)
+static int _id_valid(struct id *id, int e)
 {
 	int i;
 
@@ -140,13 +140,20 @@ int id_valid(struct id *id)
 
 	for (i = 0; i < ID_LEN; i++)
 		if (!_inverse_c[id->uuid[i]]) {
-			log_error("UUID contains invalid character '%c'", id->uuid[i]);
+			if (e)
+				log_error("UUID contains invalid character '%c'", id->uuid[i]);
 			return 0;
 		}
 
 	return 1;
 }
 
+int id_valid(struct id *id)
+{
+	return _id_valid(id, 1);
+}
+
+
 int id_equal(const struct id *lhs, const struct id *rhs)
 {
 	return !memcmp(lhs->uuid, rhs->uuid, sizeof(lhs->uuid));
@@ -179,7 +186,7 @@ int id_write_format(const struct id *id, char *buffer, size_t size)
 	return 1;
 }
 
-int id_read_format(struct id *id, const char *buffer)
+static int _id_read_format(struct id *id, const char *buffer, int e)
 {
 	int out = 0;
 
@@ -192,7 +199,8 @@ int id_read_format(struct id *id, const char *buffer)
 		}
 
 		if (out >= ID_LEN) {
-			log_error("Too many characters to be uuid.");
+			if (e)
+				log_error("Too many characters to be uuid.");
 			return 0;
 		}
 
@@ -200,12 +208,23 @@ int id_read_format(struct id *id, const char *buffer)
 	}
 
 	if (out != ID_LEN) {
-		log_error("Couldn't read uuid: incorrect number of "
-			  "characters.");
+		if (e)
+			log_error("Couldn't read uuid: incorrect number of "
+				  "characters.");
 		return 0;
 	}
 
-	return id_valid(id);
+	return _id_valid(id, e);
+}
+
+int id_read_format(struct id *id, const char *buffer)
+{
+	return _id_read_format(id, buffer, 1);
+}
+
+int id_read_format_try(struct id *id, const char *buffer)
+{
+	return _id_read_format(id, buffer, 0);
 }
 
 char *id_format_and_copy(struct dm_pool *mem, const struct id *id)
diff --git a/lib/uuid/uuid.h b/lib/uuid/uuid.h
index d87de73..8ca6352 100644
--- a/lib/uuid/uuid.h
+++ b/lib/uuid/uuid.h
@@ -56,6 +56,10 @@ int id_write_format(const struct id *id, char *buffer, size_t size);
  * Reads a formatted uuid.
  */
 int id_read_format(struct id *id, const char *buffer);
+/*
+ * Tries to read a formatted uuid without logging error for invalid ID
+ */
+int id_read_format_try(struct id *id, const char *buffer);
 
 char *id_format_and_copy(struct dm_pool *mem, const struct id *id);
 


