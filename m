From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Jun 2018 16:27:58 -0400
Subject: master - vgchange: start polling with option
Message-ID: <201806112027.w5BKRwuh030011@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=75fed05d3ef648583764ff56cc577e0f3eba1bba
Commit:        75fed05d3ef648583764ff56cc577e0f3eba1bba
Parent:        e82b70e7399b20dd201e8d7fad182ce276596fb2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 11 22:18:00 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 11 22:25:42 2018 +0200

vgchange: start polling with option

Polling start either with '--refresh'
or with '--poll' option specified.
---
 tools/vgchange.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index b07057f..b427a81 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -662,6 +662,7 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (!arg_is_set(cmd, refresh_ARG) &&
+	    arg_is_set(cmd, poll_ARG) &&
 	    !vgchange_background_polling(cmd, vg))
 		return_ECMD_FAILED;
 


