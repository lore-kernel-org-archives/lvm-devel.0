From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:34 +0000 (UTC)
Subject: master - coverity: fix memory access
Message-ID: <20160421231834.7E250616D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cbf99be43a70e872b5040ffa0193a8f4961a7068
Commit:        cbf99be43a70e872b5040ffa0193a8f4961a7068
Parent:        556eba183520821e6fb709253e3e12ba48a5fcdf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 20:21:59 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 01:11:57 2016 +0200

coverity: fix memory access

Commit  52e0d0db4460d90172e9bd45b9ef30e7f4f75ae7 introduced regression
as code may access   buf[0 - 1].

Reorder code to first remove '\n' and then check buffer size for
empty.
---
 WHATS_NEW              |    1 +
 lib/device/dev-cache.c |   16 ++++++----------
 2 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1e47c20..ffc83f5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151 -
 =================================
+  Fix memory access for empty sysfs values (2.02.149).
   Disable lvmetad when lvm1 metadata is seen, so commands revert to scanning.
   Suppress errors when snapshot merge gets delayed because volume is in use.
   Avoid internal snapshot LV names in messages.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index b5f2152..7a124d0 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -379,17 +379,13 @@ static int _get_sysfs_value(const char *path, char *buf, size_t buf_size, int er
 		goto out;
 	}
 
-	if (!(len = strlen(buf)) || (len == 1 && buf[0] == '\n')) {
-		if (error_if_no_value) {
-			log_error("_get_sysfs_value: %s: no value", path);
-			goto out;
-		}
-	}
+	if ((len = strlen(buf)) && buf[len - 1] == '\n')
+		buf[--len] = '\0';
 
-	if (buf[len - 1] == '\n')
-		buf[len - 1] = '\0';
-
-	r = 1;
+	if (!len && error_if_no_value)
+		log_error("_get_sysfs_value: %s: no value", path);
+	else
+		r = 1;
 out:
 	if (fclose(fp))
 		log_sys_error("fclose", path);


