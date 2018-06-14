From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:03:01 -0400
Subject: master - vgchange: move active assing
Message-ID: <201806142003.w5EK319k003578@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f38a54227d71b6fd661d83609f46459306bc373a
Commit:        f38a54227d71b6fd661d83609f46459306bc373a
Parent:        70b159d145dfa960a53f6f61ce735b90ec25b1e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 21:00:16 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

vgchange: move active assing

Make eval of activate_ARG reusable.
---
 tools/vgchange.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index b608d87..71a6c54 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -586,6 +586,7 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 {
 	int ret = ECMD_PROCESSED;
 	unsigned i;
+	activation_change_t activate = CHANGE_AN;
 
 	static const struct {
 		int arg;
@@ -642,8 +643,8 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (arg_is_set(cmd, activate_ARG)) {
-		if (!vgchange_activate(cmd, vg, (activation_change_t)
-				       arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
+		activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, 0);
+		if (!vgchange_activate(cmd, vg, activate))
 			return_ECMD_FAILED;
 	}
 


