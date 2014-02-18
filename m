From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Feb 2014 20:28:27 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140218202827.4F3BD60CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=750a310a40c09cd222d52299f2d682082d6a133c
Commit:        750a310a40c09cd222d52299f2d682082d6a133c
Parent:        e6fd16f8ea5e859925268838dba9341527c91a4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 18 21:21:06 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 18 21:22:00 2014 +0100

cleanup: indent

---
 tools/vgchange.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 814238b..cb2d84b 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -597,8 +597,8 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, activate_ARG) == 1
-	    && arg_count(cmd, autobackup_ARG)) {
+	if ((arg_count(cmd, activate_ARG) == 1) &&
+	    arg_count(cmd, autobackup_ARG)) {
 		log_error("-A option not necessary with -a option");
 		return EINVALID_CMD_LINE;
 	}


