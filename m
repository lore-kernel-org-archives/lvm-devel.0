From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 24 Jun 2010 12:37:53 -0400
Subject: [PATCH] lvm2: add missing argument for yes_no_prompt() in remove_mirror_log()
Message-ID: <4C2389E1.5080408@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a missing parameter, lv->name, for yes_no_prompt() in remove_mirror_log().


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/metadata/mirror.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: LVM2-2.02.68/lib/metadata/mirror.c
===================================================================
--- LVM2-2.02.68.orig/lib/metadata/mirror.c
+++ LVM2-2.02.68/lib/metadata/mirror.c
@@ -1543,7 +1543,7 @@ int remove_mirror_log(struct cmd_context
 		return 0;
 	} else if (yes_no_prompt("Full resync required to convert "
 				 "inactive mirror %s to core log. "
-				 "Proceed? [y/n]: ") == 'y')
+				 "Proceed? [y/n]: ", lv->name) == 'y')
 		sync_percent = 0;
 	else
 		return 0;


