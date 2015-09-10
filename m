From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 10 Sep 2015 14:50:22 +0000 (UTC)
Subject: master - vgchange: lock-stop only needs shared lock
Message-ID: <20150910145022.8F72760EE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30e489db5e05296e22037bd885d074d395ab46f4
Commit:        30e489db5e05296e22037bd885d074d395ab46f4
Parent:        2296999cf6922b2be0c6dc38abae0c6766996060
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 9 13:09:17 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 10 09:47:26 2015 -0500

vgchange: lock-stop only needs shared lock

lock-stop is one of the vgchange options that
doesn't change the VG so we can override the
default ex lock and use sh.
---
 tools/vgchange.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 1d3c64a..a80b678 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1044,6 +1044,9 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 			cmd->lockd_vg_enforce_sh = 1;
 	}
 
+	if (arg_is_set(cmd, lockstop_ARG))
+		cmd->lockd_vg_default_sh = 1;
+
 	/* Starting a vg lockspace means there are no locks available yet. */
 
 	if (arg_is_set(cmd, lockstart_ARG))


