From: David Teigland <teigland@sourceware.org>
Date: Tue, 28 Feb 2017 16:58:22 -0500
Subject: master - help: print full usage for lvm help all
Message-ID: <201702282158.v1SLwMG0028452@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1828822bd8ad773d57d90841cb4036b49f3653b1
Commit:        1828822bd8ad773d57d90841cb4036b49f3653b1
Parent:        ce1e5b99915cf45530e25628f02537136045c938
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 28 15:57:30 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 28 15:58:14 2017 -0600

help: print full usage for lvm help all

---
 tools/lvmcmdline.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9b20d9f..d440987 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1732,7 +1732,7 @@ static void _usage_all(void)
 	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
 		if (!command_names[i].name)
 			break;
-		_usage(command_names[i].name, 0);
+		_usage(command_names[i].name, 1);
 	}
 }
 


