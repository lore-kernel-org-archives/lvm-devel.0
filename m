From: Milan Broz <mbroz@redhat.com>
Date: Sat, 23 Jan 2010 21:58:43 +0100
Subject: [PATCH 1/6] Fix return code of info callbacks.
Message-ID: <1264280328-8728-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In dev_manager_info 0 means error and 1 info is returned,
not that device exist (that value is part of info struct).

Fix query by uuid only (no name) which returns 0 when device
do not exist.
---
 lib/activate/dev_manager.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 25b7a10..6023574 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -209,14 +209,16 @@ static int _info(const char *name, const char *dlid, int mknodes,
 		 int with_open_count, int with_read_ahead,
 		 struct dm_info *info, uint32_t *read_ahead)
 {
+	int r = 0;
+
 	if (!mknodes && dlid && *dlid) {
-		if (_info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
-			      with_read_ahead, 0, 0) &&
+		if ((r = _info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
+			      with_read_ahead, 0, 0)) &&
 	    	    info->exists)
 			return 1;
-		else if (_info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
+		else if ((r = _info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
 				   read_ahead, 0, with_open_count,
-				   with_read_ahead, 0, 0) &&
+				   with_read_ahead, 0, 0)) &&
 			 info->exists)
 			return 1;
 	}
@@ -225,7 +227,7 @@ static int _info(const char *name, const char *dlid, int mknodes,
 		return _info_run(name, NULL, info, read_ahead, mknodes,
 				 with_open_count, with_read_ahead, 0, 0);
 
-	return 0;
+	return r;
 }
 
 static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
-- 
1.6.6


