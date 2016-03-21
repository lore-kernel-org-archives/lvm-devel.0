From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Mar 2016 14:50:39 +0000 (UTC)
Subject: master - dev: be safer when reading sysfs properties
Message-ID: <20160321145039.39FFA60E41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8fad9b9e5d219861fc1f758216fb446cffe3817f
Commit:        8fad9b9e5d219861fc1f758216fb446cffe3817f
Parent:        ca7bac53cf0b3b64bdfa375085fc1535589ab1eb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 21 15:48:36 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 21 15:50:32 2016 +0100

dev: be safer when reading sysfs properties

Check if the value we read from sysfs is not blank and replace the '\n'
at the end only when needed ('\n' should usually be there for sysfs values,
but better check this).
---
 lib/device/dev-cache.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 490cec3..d912dea 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -365,6 +365,7 @@ static int _add_alias(struct device *dev, const char *path)
 static int _get_sysfs_value(const char *path, char *buf, size_t buf_size)
 {
 	FILE *fp;
+	size_t len;
 
 	if (!(fp = fopen(path, "r"))) {
 		log_sys_error("fopen", path);
@@ -378,7 +379,13 @@ static int _get_sysfs_value(const char *path, char *buf, size_t buf_size)
 		return 0;
 	}
 
-	buf[strlen(buf) - 1] = '\0';
+	if (!(len = strlen(buf))) {
+		log_error("_get_sysfs_value: %s: no value", path);
+		return 0;
+	}
+
+	if (buf[len - 1] == '\n')
+		buf[len - 1] = '\0';
 
 	if (fclose(fp))
 		log_sys_error("fclose", path);


