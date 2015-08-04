From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  4 Aug 2015 08:26:00 +0000 (UTC)
Subject: master - coverity: return value check in lvmlockd-dlm
Message-ID: <20150804082600.CF5B6609D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c78033233ab03749b37c01454310ac0c29fd5af8
Commit:        c78033233ab03749b37c01454310ac0c29fd5af8
Parent:        83541123c81b8ff129175963866d9fbd01c21e38
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 4 09:49:23 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 4 09:49:29 2015 +0200

coverity: return value check in lvmlockd-dlm

daemons/lvmlockd/lvmlockd-dlm.c:647: check_return: Calling "closedir" without checking return value (as is done elsewhere 13 out of 14 times).
---
 daemons/lvmlockd/lvmlockd-dlm.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index f1b060a..c96866b 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -616,6 +616,7 @@ int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
 
 int lm_get_lockspaces_dlm(struct list_head *ls_rejoin)
 {
+	static const char closedir_err_msg[] = "lm_get_lockspace_dlm: closedir failed";
 	struct lockspace *ls;
 	struct dirent *de;
 	DIR *ls_dir;
@@ -632,7 +633,7 @@ int lm_get_lockspaces_dlm(struct list_head *ls_rejoin)
 
 		if (!(ls = alloc_lockspace())) {
 			if (closedir(ls_dir))
-				log_error("lm_get_lockspace_dlm: closedir failed");
+				log_error(closedir_err_msg);
 			return -ENOMEM;
 		}
 
@@ -642,7 +643,8 @@ int lm_get_lockspaces_dlm(struct list_head *ls_rejoin)
 		list_add_tail(&ls->list, ls_rejoin);
 	}
 
-	closedir(ls_dir);
+	if (closedir(ls_dir))
+		log_error(closedir_err_msg);
 	return 0;
 }
 


