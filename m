From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Dec 2022 18:07:25 +0000 (GMT)
Subject: main - device_id: add null id->name null check
Message-ID: <20221201180725.412453858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7552ed9010f823d2ac2b99349c62dce8cd6fd506
Commit:        7552ed9010f823d2ac2b99349c62dce8cd6fd506
Parent:        f80273a1071532115219ea7c23054e6bbb096039
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 1 10:38:48 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 1 10:38:48 2022 -0600

device_id: add null id->name null check

for covscan
---
 lib/device/device_id.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index aae875776..4fa02edc7 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1844,8 +1844,8 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
 				return 1;
 
-			} else if ((id->idtype == DEV_ID_TYPE_SYS_WWID) && !strncmp(id->idname, "t10", 3) &&
-				    du_t10[0] && !strcmp(id->idname, du_t10)) {
+			} else if ((id->idtype == DEV_ID_TYPE_SYS_WWID) && id->idname &&
+				   !strncmp(id->idname, "t10", 3) && du_t10[0] && !strcmp(id->idname, du_t10)) {
 				/* Compare the shorter form du t10 wwid to the dev t10 wwid. */
 				du->dev = dev;
 				dev->id = id;

