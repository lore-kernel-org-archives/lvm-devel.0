From: Milan Broz <mbroz@redhat.com>
Date: Sat, 23 Jan 2010 21:58:45 +0100
Subject: [PATCH 3/6] Unlock shared lock if activation calls failed.
In-Reply-To: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
References: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
Message-ID: <1264280328-8728-3-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Clvmd should unlock new lock if activation in device-mapper fails.
---
 daemons/clvmd/lvm-functions.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 74c660e..02d401b 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -373,17 +373,22 @@ static int do_activate_lv(char *resource, unsigned char lock_flags, int mode)
 
 	/* If it's suspended then resume it */
 	if (!lv_info_by_lvid(cmd, resource, &lvi, 0, 0))
-		return EIO;
+		goto error;
 
 	if (lvi.suspended)
 		if (!lv_resume(cmd, resource))
-			return EIO;
+			goto error;
 
 	/* Now activate it */
 	if (!lv_activate(cmd, resource, exclusive))
-		return EIO;
+		goto error;
 
 	return 0;
+
+error:
+	if (oldmode == -1 || oldmode != mode)
+		(void)hold_unlock(resource);
+	return EIO;
 }
 
 /* Resume the LV if it was active */
-- 
1.6.6


