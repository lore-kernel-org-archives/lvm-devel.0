From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:31 +0000 (UTC)
Subject: master - cleanup: dmeventd reorder _fill_device_data
Message-ID: <20140418145531.7E2FD6109E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4fb588c34ee9b64333ad39ab039d657cf6e958ab
Commit:        4fb588c34ee9b64333ad39ab039d657cf6e958ab
Parent:        6b701c3a48aede064850f7b3d16021d60fa8e541
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 11:37:17 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:51 2014 +0200

cleanup: dmeventd reorder _fill_device_data

Just simplify the function.
---
 daemons/dmeventd/dmeventd.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 4f059b9..a907ca6 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -404,6 +404,7 @@ static int _fill_device_data(struct thread_status *ts)
 {
 	struct dm_task *dmt;
 	struct dm_info dmi;
+	int ret = 0;
 
 	if (!ts->device.uuid)
 		return 0;
@@ -426,16 +427,11 @@ static int _fill_device_data(struct thread_status *ts)
 
 	ts->device.major = dmi.major;
 	ts->device.minor = dmi.minor;
-
-	dm_task_destroy(dmt);
-	return 1;
-
-      fail:
+	ret = 1;
+fail:
 	dm_task_destroy(dmt);
-	dm_free(ts->device.name);
-	ts->device.name = NULL;
 
-	return 0;
+	return ret;
 }
 
 /*


