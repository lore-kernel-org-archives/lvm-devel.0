From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Feb 2015 10:29:28 +0000 (UTC)
Subject: master - lvchange: change msg about required params (LV or selection) to be consistent with msgs used in other tools
Message-ID: <20150213102928.CC733613B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1710f34bbbb46f8f6c6cc7ba284a4cbdac6dc2e
Commit:        e1710f34bbbb46f8f6c6cc7ba284a4cbdac6dc2e
Parent:        e4e703ab60dc912d3d8c7ff198c98962338341b2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 13 09:04:21 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 13 09:04:21 2015 +0100

lvchange: change msg about required params (LV or selection) to be consistent with msgs used in other tools

---
 tools/lvchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index f45469e..c9466ec 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1153,7 +1153,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		cmd->handles_missing_pvs = 1;
 
 	if (!argc && !arg_is_set(cmd, select_ARG)) {
-		log_error("Please give logical volume path(s) or provide selection criteria.");
+		log_error("Please give logical volume path(s) or use -S for selection.");
 		return EINVALID_CMD_LINE;
 	}
 


