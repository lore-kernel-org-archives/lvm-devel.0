From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Nov 2021 16:41:59 +0000 (GMT)
Subject: main - pvscan: limit md device_hint for slow autoactivation
Message-ID: <20211130164159.F2D85385801B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=470b967bc5a66b3b066af5694a10220be7a2a155
Commit:        470b967bc5a66b3b066af5694a10220be7a2a155
Parent:        d12baba1a9bfe2d82537b20bc768758d84b263b6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 30 09:06:08 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 30 09:06:08 2021 -0600

pvscan: limit md device_hint for slow autoactivation

The device_hint name in the metadata was meant to prevent
autoactivation from md components, but the name checks were
more general and would catch unnecessary cases.
---
 tools/pvscan.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 0c25fb542..429b5e676 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -564,7 +564,8 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 		name1 = dev_name(dev);
 		name2 = pvl->pv->device_hint;
 
-		if (strcmp(name1, name2)) {
+		/* Probably pointless since dev is from online file which was already checked. */
+		if (!strncmp(name2, "/dev/md", 7) && strncmp(name1, "/dev/md", 7)) {
 			if (!id_write_format((const struct id *)pvid, uuidstr, sizeof(uuidstr)))
 				uuidstr[0] = '\0';
 			log_print_pvscan(cmd, "PVID %s read from %s last written to %s.", uuidstr, name1, name2);
@@ -1119,7 +1120,7 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 		do_full_check = 0;
 
 		/* If use_full_md_check is set then this has already been done by filter. */
-		if (!cmd->use_full_md_check) {
+		if (!cmd->use_full_md_check && (cmd->dev_types->md_major != MAJOR(dev->dev))) {
 			if (devsize && (pv->size != devsize))
 				do_full_check = 1;
 			if (pv->device_hint && !strncmp(pv->device_hint, "/dev/md", 7))


