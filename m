From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:49:05 +0000 (UTC)
Subject: master - cleanup: convert log_error with log_warn
Message-ID: <20131128114905.9E58E606DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6bf6430ae94e2a0e8239b198e35b53abbaa3f041
Commit:        6bf6430ae94e2a0e8239b198e35b53abbaa3f041
Parent:        5bdbaf4ed7a0f8b8e032d4f8d76bb63f8ec071b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 25 14:34:34 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:48:01 2013 +0100

cleanup: convert log_error with log_warn

Collapse 2 ifs and replace log_error() with log_warn(), since\
the reported message is not causing tools error.
(and cannot be probably triggered anyway).
---
 lib/activate/dev_manager.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e53273d..bed4d60 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -112,9 +112,9 @@ static int _info_run(const char *name, const char *dlid, struct dm_info *info,
 	if (!(dmt = _setup_task(mknodes ? name : NULL, dlid, 0, dmtask, major, minor)))
 		return_0;
 
-	if (!with_open_count)
-		if (!dm_task_no_open_count(dmt))
-			log_error("Failed to disable open_count");
+	if (!with_open_count &&
+	    !dm_task_no_open_count(dmt))
+		log_warn("WARNING: Failed to disable open_count.");
 
 	if (!dm_task_run(dmt))
 		goto_out;


