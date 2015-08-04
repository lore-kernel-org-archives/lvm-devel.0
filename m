From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  4 Aug 2015 08:25:56 +0000 (UTC)
Subject: master - coverity: fix possible resource leak in lvmpolld-core
Message-ID: <20150804082556.7D654609D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46e6b2b86e58e081fa40e9cc724f09f03ecf843e
Commit:        46e6b2b86e58e081fa40e9cc724f09f03ecf843e
Parent:        6ac5689ce4d4f86c4b3985d73a0fdb4af04c298d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 4 09:25:40 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 4 09:25:47 2015 +0200

coverity: fix possible resource leak in lvmpolld-core

/daemons/lvmpolld/lvmpolld-core.c:573: leaked_storage: Variable "cmdargv" going out of scope leaks the storage it points to.
---
 daemons/lvmpolld/lvmpolld-core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index 1da2da2..1402373 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -566,6 +566,8 @@ static struct lvmpolld_lv *construct_pdlv(request req, struct lvmpolld_state *ls
 		return NULL;
 	}
 
+	pdlv->cmdargv = cmdargv;
+
 	cmdenvp = cmdenvp_ctr(pdlv);
 	if (!cmdenvp) {
 		pdlv_destroy(pdlv);
@@ -573,7 +575,6 @@ static struct lvmpolld_lv *construct_pdlv(request req, struct lvmpolld_state *ls
 		return NULL;
 	}
 
-	pdlv->cmdargv = cmdargv;
 	pdlv->cmdenvp = cmdenvp;
 
 	return pdlv;


