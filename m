From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:10 -0500
Subject: master - gcc: avoid declaration shadowing
Message-ID: <37271.119111116460503319@us-mta-200.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8679d45917c321ea76c48c150395db833ba7b812
Commit:        8679d45917c321ea76c48c150395db833ba7b812
Parent:        e184f77109d973297fa80edaa8dca7447b64b40e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 19:35:28 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:18 2019 +0100

gcc: avoid declaration shadowing

dev_name is global in device.h
---
 lib/activate/dev_manager.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1adb44d..51ba298 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -259,7 +259,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 	void *target = NULL;
 	uint64_t target_start, target_length, start, length;
 	char *target_name, *target_params;
-	const char *dev_name;
+	const char *devname;
 
 	if (seg_status) {
 		dmtask = DM_DEVICE_STATUS;
@@ -274,8 +274,8 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 		return_0;
 
 	if (name_check && dminfo->exists &&
-	    (dev_name = dm_task_get_name(dmt)) &&
-	    (strcmp(name_check, dev_name) != 0))
+	    (devname = dm_task_get_name(dmt)) &&
+	    (strcmp(name_check, devname) != 0))
 		dminfo->exists = 0;	/* mismatching name -> device does not exist */
 
 	if (with_read_ahead && dminfo->exists) {



