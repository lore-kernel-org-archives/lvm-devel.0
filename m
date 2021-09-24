From: David Teigland <teigland@sourceware.org>
Date: Fri, 24 Sep 2021 20:41:57 +0000 (GMT)
Subject: main - lvmlockd: update error message
Message-ID: <20210924204157.2CC273858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e62a71f3dd97795ea64b2f3948dd8629c2dac8b8
Commit:        e62a71f3dd97795ea64b2f3948dd8629c2dac8b8
Parent:        a1cb33b633c7d4c76e86bc71ceae043555366a4e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 24 15:39:36 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 24 15:40:20 2021 -0500

lvmlockd: update error message

refer specifically to the "use_lvmlockd" setting in lvm.conf
---
 tools/toollib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0576a76fb..606d35981 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -677,7 +677,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 			}
 
 		} else {
-			log_error("Using a shared lock type requires lvmlockd.");
+			log_error("Using a shared lock type requires lvmlockd (lvm.conf use_lvmlockd.)");
 			return 0;
 		}
 


