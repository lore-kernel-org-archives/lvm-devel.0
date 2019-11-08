From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Nov 2019 09:14:55 -0500
Subject: stable-2.02 - cov: ensure read_ahead is available
Message-ID: <201911081414.xA8EEsCN008286@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f90c3d69cedf94fa094bc71cc98376d58d970223
Commit:        f90c3d69cedf94fa094bc71cc98376d58d970223
Parent:        67bdae069751e4779e738283e3d8a5873622bfc0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 21:01:51 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 8 13:04:45 2019 +0100

cov: ensure  read_ahead is available

Make sure read_ahead pointer is not NULL when quering for RA.
---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index feec861..7acb3e9 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -270,7 +270,7 @@ static int _info_run(const char *dlid, struct dm_info *dminfo,
 	    (strcmp(name_check, devname) != 0))
 		dminfo->exists = 0;	/* mismatching name -> device does not exist */
 
-	if (with_read_ahead && dminfo->exists) {
+	if (with_read_ahead && read_ahead && dminfo->exists) {
 		if (!dm_task_get_read_ahead(dmt, read_ahead))
 			goto_out;
 	} else if (read_ahead)


