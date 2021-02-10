From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Feb 2021 21:43:30 +0000 (GMT)
Subject: main - scan: wipe filters when dropping scanned data
Message-ID: <20210210214330.E2C3D39C077A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c94d78f068653293e42f0fe815ddeef98406c666
Commit:        c94d78f068653293e42f0fe815ddeef98406c666
Parent:        f49bedc0295d4b038004adfda64fafcfa8b1d2c7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 10 14:06:58 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 10 15:34:45 2021 -0600

scan: wipe filters when dropping scanned data

Fix clearing persistent filter state when clearing all
the state from a label_scan.

label_scan reads devs and saves info in bcache, lvmcache,
and in the persistent filter.  In some uncommon cases, an
lvm command wants to clear all info from a prior label_scan,
and repeat label_scan from scratch.  In these cases, info
in lvmcache, bcache and the persistent filter all need to
be cleared before repeating label_scan.

By missing the persistent filter wiping, outdated persistent
filter info, from a prior label_scan, could cause lvm to
incorrectly filter devices that change between polling intervals.
(i.e. if the device changes in such a way that the filtering
results change.)

A case where lvm wants to do multiple label_scans is a
polling command (like lvconvert --merge), when lvmpolld
has been disabled, so that the command itself needs to
to do repeated polling checks.
---
 lib/label/label.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 030d2c578..0fc832c08 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -707,19 +707,6 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		if (!rem_prefetches)
 			break;
 
-		/* FIXME: figure better solution to avoid opening DM we shouldn't open */
-		if (dm_is_dm_major(MAJOR(devl->dev->dev)) &&
-		    !device_is_usable(devl->dev, (struct dev_usable_check_params) {
-					.check_blocked = 1,
-					.check_suspended = ignore_suspended_devices(),
-					.check_reserved = 1,
-					.check_error_target = 1,
-				      })) {
-			log_debug_devs("Scan skips unusuable DM device %s.", dev_name(devl->dev));
-			dm_list_del(&devl->list);
-			continue;
-		}
-
 		if (!_in_bcache(devl->dev)) {
 			if (!_scan_dev_open(devl->dev)) {
 				log_debug_devs("Scan failed to open %s.", dev_name(devl->dev));
@@ -1432,6 +1419,7 @@ void label_scan_drop(struct cmd_context *cmd)
 		return;
 
 	while ((dev = dev_iter_get(cmd, iter))) {
+		cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
 		if (_in_bcache(dev))
 			_scan_dev_close(dev);
 	}


