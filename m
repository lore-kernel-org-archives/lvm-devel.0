From: David Teigland <teigland@sourceware.org>
Date: Wed, 26 Jun 2019 17:06:44 -0400
Subject: stable-2.02 - pvremove/vgextend: fix using device aliases with lvmetad
Message-ID: <201906262106.x5QL6iQR011476@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b13ebfa4c289a5bc6eb4f8ba26126db8e6d78296
Commit:        b13ebfa4c289a5bc6eb4f8ba26126db8e6d78296
Parent:        b62c0787debeb3a66a2e3658d1edb8a61a6f247b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 26 16:03:42 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 26 16:06:23 2019 -0500

pvremove/vgextend: fix using device aliases with lvmetad

These commands were looking for the requested device alias
before dev_cache_scan had created the list of devs on the
system, so they would fail and report the dev wasn't found.
---
 tools/toollib.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 3221e5f..1b01ccc 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5544,6 +5544,15 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	lvmcache_label_scan(cmd);
 
 	/*
+	 * When using lvmetad, we want to do a dev cache scan here (if not done
+	 * already) so that the dev_cache_get just below will be able to find
+	 * device aliases.  When not using lvmetad, the label_scan just above
+	 * has done dev_cache_scan, and this will not be run.
+	 */
+	if (!dev_cache_has_scanned())
+		dev_cache_scan();
+
+	/*
 	 * Translate arg names into struct device's.
 	 */
 	dm_list_iterate_items(pd, &pp->arg_devices)


