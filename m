From: David Teigland <teigland@sourceware.org>
Date: Tue,  4 May 2021 18:08:52 +0000 (GMT)
Subject: main - pvremove: use consistent error message
Message-ID: <20210504180852.4ECD8395144A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2419345b9d407d8b07327d7484f765ee92be5994
Commit:        2419345b9d407d8b07327d7484f765ee92be5994
Parent:        4dc5d4ac7e7a9457ccc46ff04796b347e58bf4da
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 4 13:03:25 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 4 13:08:02 2021 -0500

pvremove: use consistent error message

When the device is not a PV print
  "No PV found on device ..."

instead of
  "Failed to read lvm info for ... PVID ."

an earlier check had been added with a different
message for the same condition.
---
 tools/toollib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 8f9ea1e6b..07f065322 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5028,7 +5028,7 @@ static int _pvremove_check_used(struct cmd_context *cmd,
 	if (!(info = lvmcache_info_from_pvid(pd->dev->pvid, pd->dev, 0))) {
 		if (pp->force)
 			return 1;
-		log_error("Failed to read lvm info for %s PVID %s.", dev_name(pd->dev), pd->dev->pvid);
+		log_error("No PV found on device %s.", dev_name(pd->dev));
 		dm_list_move(&pp->arg_fail, &pd->list);
 		return 0;
 	}


