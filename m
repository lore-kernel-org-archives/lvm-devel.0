From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Apr 2013 09:31:28 +0000 (UTC)
Subject: master - dmsetup: check for strncpy
Message-ID: <20130412093128.671162111@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58734d2538854ef79e6605ba69c57723737d12c2
Commit:        58734d2538854ef79e6605ba69c57723737d12c2
Parent:        a81a2406f18c6ad0802a02892214f56b1bb99c13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 18:34:12 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 12 11:30:47 2013 +0200

dmsetup: check for strncpy

Test whether device name fits into a given buffer.
---
 tools/dmsetup.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ce46d6c..8f6b340 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3244,20 +3244,19 @@ static char *parse_loop_device_name(const char *dev, const char *dev_dir)
 		    device[strlen(dev_dir)] != '/')
 			goto error;
 
-		strncpy(buf, strrchr(device, '/') + 1, PATH_MAX - 1);
-		buf[PATH_MAX - 1] = '\0';
+		if (!dm_strncpy(buf, strrchr(device, '/') + 1, PATH_MAX))
+			goto error;
 		dm_free(device);
-
 	} else {
 		/* check for device number */
-		if (!strncmp(dev, "loop", strlen("loop")))
-			strncpy(buf, dev, (size_t) PATH_MAX);
-		else
+		if (strncmp(dev, "loop", sizeof("loop") - 1))
+			goto error;
+
+		if (!dm_strncpy(buf, dev, PATH_MAX))
 			goto error;
 	}
 
 	return buf;
-
 error:
 	dm_free(device);
 	dm_free(buf);


