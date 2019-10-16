From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Oct 2019 14:33:59 -0400
Subject: stable-2.02 - devs: check for no dev when dropping aliases
Message-ID: <201910161833.x9GIXxnM011280@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f50af80199f723f7b1970ee33ddf959ea79fcbef
Commit:        f50af80199f723f7b1970ee33ddf959ea79fcbef
Parent:        219c4c2ce2c605960ad760ac99be27b2665a8c43
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 16 13:32:28 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 16 13:32:28 2019 -0500

devs: check for no dev when dropping aliases

When scanning fails to find a device path and
looks for device aliases, check if the device
itself still exists to avoid a potential segfault.
---
 lib/label/label.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 8107e33..e4a1068 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -734,6 +734,11 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 		retried_open = 1;
 
 		dm_list_iterate_items_safe(devl, devl2, &reopen_devs) {
+			if (!devl->dev) {
+				dm_list_del(&devl->list);
+				continue;
+			}
+
 			_drop_bad_aliases(devl->dev);
 
 			if (dm_list_empty(&devl->dev->aliases)) {


