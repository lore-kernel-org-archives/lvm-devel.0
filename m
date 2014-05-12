From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 May 2014 14:25:50 +0000 (UTC)
Subject: master - cleanup: cast int to typedef
Message-ID: <20140512142550.BA3796106E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=506ade802b6e7f8c2afb027cd969bbb105afabd1
Commit:        506ade802b6e7f8c2afb027cd969bbb105afabd1
Parent:        90c44f5371b85edb05d4c4ebbd9e0254971d13f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 9 16:13:48 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 12 16:24:40 2014 +0200

cleanup: cast int to typedef

---
 tools/vgchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 2856b28..d24b17e 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -590,7 +590,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_count(cmd, activate_ARG) &&
 	    (arg_count(cmd, monitor_ARG) || arg_count(cmd, poll_ARG))) {
-		if (!is_change_activating(arg_uint_value(cmd, activate_ARG, 0))) {
+		if (!is_change_activating((activation_change_t) arg_uint_value(cmd, activate_ARG, 0))) {
 			log_error("Only -ay* allowed with --monitor or --poll.");
 			return EINVALID_CMD_LINE;
 		}


