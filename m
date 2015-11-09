From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:35 +0000 (UTC)
Subject: master - dev-type: fix TOCTOU order
Message-ID: <20151109092835.2B78D60DE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa1d73084769ea4a6d07434e12dcae519938e4c5
Commit:        fa1d73084769ea4a6d07434e12dcae519938e4c5
Parent:        80c3fb786cc236f200026624ded4c668b37ef22d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 8 17:15:24 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:20 2015 +0100

dev-type: fix TOCTOU order

Doing 'stat' checking first and later opening is racy.
And since we do not really care about any 'status' info
here and we read 'sysfs' here - just drop whole 'stat()'
call and directly handle error from failing 'fopen()'.
---
 WHATS_NEW             |    1 +
 lib/device/dev-type.c |   13 +++----------
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6368b32..19f24f7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Drop unneeded stat() call when checking for sysfs file.
   Fix memory leak on error path of failing thin-pool percentage check.
   Add missing test for failing node allocation in lvmetad.
   Correct configure messages when enabling/disabling lvmlockd.
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index a66ef95..e1243bd 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -462,7 +462,6 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 		*result = dev->dev;
 		ret = 1;
 		goto out; /* dev is not a partition! */
-
 	}
 
 	/*
@@ -486,17 +485,11 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	}
 
 	/* finally, parse 'dev' attribute and create corresponding dev_t */
-	if (stat(path, &info) == -1) {
+	if (!(fp = fopen(path, "r"))) {
 		if (errno == ENOENT)
-			log_error("sysfs file %s does not exist", path);
+			log_error("sysfs file %s does not exist.", path);
 		else
-			log_sys_error("stat", path);
-		goto out;
-	}
-
-	fp = fopen(path, "r");
-	if (!fp) {
-		log_sys_error("fopen", path);
+			log_sys_error("fopen", path);
 		goto out;
 	}
 


