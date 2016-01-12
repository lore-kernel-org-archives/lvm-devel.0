From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 Jan 2016 10:42:53 +0000 (UTC)
Subject: master - vgchange: drop redundant check
Message-ID: <20160112104253.162E660B3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1e30ff0baa3cf4ae0c582c29dc017d63ca99483
Commit:        d1e30ff0baa3cf4ae0c582c29dc017d63ca99483
Parent:        d09246a07d3e4d9940cdbbd017b1bc8319384081
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Jan 12 10:15:10 2016 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Jan 12 11:41:41 2016 +0100

vgchange: drop redundant check

check for background polling option is performed from
within vgchange_background_polling routine as well.
---
 tools/vgchange.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 3aea8a4..62e602a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -998,8 +998,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (!arg_count(cmd, refresh_ARG) &&
-	    background_polling())
-		if (!vgchange_background_polling(cmd, vg))
+	    !vgchange_background_polling(cmd, vg))
 			return_ECMD_FAILED;
 
 	if (arg_is_set(cmd, lockstart_ARG)) {


