From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:24:05 +0000 (UTC)
Subject: master - cleanup: shorter code
Message-ID: <20141103132405.AC1E760E6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce7f06cf4e62147293678c0baf0c86c45e8b4549
Commit:        ce7f06cf4e62147293678c0baf0c86c45e8b4549
Parent:        1b439a0b8e6fc99bcc66fe74c8675ceb4ab430d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 13:36:54 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

cleanup: shorter code

---
 tools/lvcreate.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f6786a8..cf2a07c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -577,7 +577,7 @@ static int _read_activation_params(struct cmd_context *cmd,
                                    struct volume_group *vg,
 				   struct lvcreate_params *lp)
 {
-	unsigned pagesize;
+	unsigned pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
 
 	lp->activate = (activation_change_t)
 		arg_uint_value(cmd, activate_ARG, CHANGE_AY);
@@ -585,7 +585,6 @@ static int _read_activation_params(struct cmd_context *cmd,
 	/* Read ahead */
 	lp->read_ahead = arg_uint_value(cmd, readahead_ARG,
 					cmd->default_settings.read_ahead);
-	pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
 	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
 	    lp->read_ahead != DM_READ_AHEAD_NONE &&
 	    lp->read_ahead % pagesize) {


