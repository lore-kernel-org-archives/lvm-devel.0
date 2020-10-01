From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Oct 2020 17:20:48 +0000 (GMT)
Subject: master - improve message for invalid device arg
Message-ID: <20201001172048.913403857C41@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74ed6e8a9969bb7d20c21f88b53e6134d81eab1d
Commit:        74ed6e8a9969bb7d20c21f88b53e6134d81eab1d
Parent:        450f272b31ef95bd7cb61812d9ef0525c7c1c341
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 1 12:19:27 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 1 12:20:16 2020 -0500

improve message for invalid device arg

for pvcreate, pvremove, vgcreate, vgextend.
---
 tools/toollib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 1814399b9..f6879745b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5248,7 +5248,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
 		pd->dev = dev_cache_get(cmd, pd->name, cmd->filter);
 		if (!pd->dev) {
-			log_error("Device %s not found.", pd->name);
+			log_error("Cannot use %s: %s", pd->name, devname_error_reason(pd->name));
 			dm_list_del(&pd->list);
 			dm_list_add(&pp->arg_fail, &pd->list);
 		}


