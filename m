From: Milan Broz <mbroz@redhat.com>
Date: Wed, 25 Mar 2009 14:33:50 +0100
Subject: [PATCH] fix question if lvconverting to core log
Message-ID: <49CA32BE.5090409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

yes_no_prompt returns 'n' or 'y'...

Why we require this always? My test case is that PV with log
fails.
Why it need resync before conversion to core log for
inactive mirror?

Signed-off-by: Milan Broz <mbroz@redhat.com>

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 304a8d9..8299c4d 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1222,7 +1222,7 @@ int remove_mirror_log(struct cmd_context *cmd,
 		return 0;
 	} else if (yes_no_prompt("Full resync required to convert "
 				 "inactive mirror %s to core log. "
-				 "Proceed? [y/n]: "))
+				 "Proceed? [y/n]: ") == 'y')
 		sync_percent = 0;
 	else
 		return 0;



