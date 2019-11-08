From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Nov 2019 09:15:14 -0500
Subject: stable-2.02 - gcc: avoid declartion shadowing
Message-ID: <201911081415.xA8EFEKS008359@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50fb24f5c208ff9b89b80a1f7aa32dcdafd98e12
Commit:        50fb24f5c208ff9b89b80a1f7aa32dcdafd98e12
Parent:        ffd959d2c0c1a5108e91efa77ac06d185fd8edb6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 19:35:28 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 8 13:03:20 2019 +0100

gcc: avoid declartion shadowing

dev_name is global in device.h
---
 lib/activate/dev_manager.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 317a2a7..feec861 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -251,7 +251,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 	void *target = NULL;
 	uint64_t target_start, target_length, start, length;
 	char *target_name, *target_params;
-	const char *dev_name;
+	const char *devname;
 
 	if (seg_status) {
 		dmtask = DM_DEVICE_STATUS;
@@ -266,8 +266,8 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 		return_0;
 
 	if (name_check && dminfo->exists &&
-	    (dev_name = dm_task_get_name(dmt)) &&
-	    (strcmp(name_check, dev_name) != 0))
+	    (devname = dm_task_get_name(dmt)) &&
+	    (strcmp(name_check, devname) != 0))
 		dminfo->exists = 0;	/* mismatching name -> device does not exist */
 
 	if (with_read_ahead && dminfo->exists) {


