From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:21 -0500
Subject: master - cov: ensure read_ahead is available
Message-ID: <09003.119111116461700609@us-mta-84.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43db8f8d5d7c773d4fe93f3bbf7ee03be4f6e36e
Commit:        43db8f8d5d7c773d4fe93f3bbf7ee03be4f6e36e
Parent:        30a23a194167d270d235afea469352f3d709a466
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 21:01:51 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:25 2019 +0100

cov: ensure read_ahead is available

Make sure read_ahead pointer is not NULL when quering for RA.
---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 51ba298..8569e86 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -278,7 +278,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 	    (strcmp(name_check, devname) != 0))
 		dminfo->exists = 0;	/* mismatching name -> device does not exist */
 
-	if (with_read_ahead && dminfo->exists) {
+	if (with_read_ahead && read_ahead && dminfo->exists) {
 		if (!dm_task_get_read_ahead(dmt, read_ahead))
 			goto_out;
 	} else if (read_ahead)



