From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:43:30 +0000 (UTC)
Subject: master - cleanup: remove superfluous forward declaration
Message-ID: <20140306114330.487E160F7B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a1d31a3c63e6e0078b4eb7e2afd43e2dcc65bc9
Commit:        9a1d31a3c63e6e0078b4eb7e2afd43e2dcc65bc9
Parent:        74a3fc4e853de50b0e5ccafcd2c9c5328dc10ad1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 6 12:43:21 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 12:43:21 2014 +0100

cleanup: remove superfluous forward declaration

---
 lib/config/config.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/config/config.h b/lib/config/config.h
index 9a8209d..5bfa345 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -63,8 +63,6 @@ typedef enum {
 	CFG_TYPE_STRING =	1 << 5,	/* setting */
 } cfg_def_type_t;
 
-typedef struct cfg_def_item cfg_def_item_t;
-
 /* function types to evaluate default value@runtime */
 typedef int (*t_fn_CFG_TYPE_BOOL) (struct cmd_context *cmd, struct profile *profile);
 typedef int (*t_fn_CFG_TYPE_INT) (struct cmd_context *cmd, struct profile *profile);


