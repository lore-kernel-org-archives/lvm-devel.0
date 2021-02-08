From: David Teigland <teigland@sourceware.org>
Date: Mon,  8 Feb 2021 17:25:00 +0000 (GMT)
Subject: main - fix for md component detection changes
Message-ID: <20210208172500.E562C385702C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=018bba897ca13521988eb36a89fd054e15feb231
Commit:        018bba897ca13521988eb36a89fd054e15feb231
Parent:        df4c50396bfce6586a063d04861f9d1d8b1aeb31
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 8 11:23:42 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 8 11:23:42 2021 -0600

fix for md component detection changes

And some fine tuning of when the checks are applied
in "start" mode.
---
 lib/cache/lvmcache.c | 56 +++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 40 insertions(+), 16 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 5c573286d..e05530a53 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1056,7 +1056,8 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 	struct device *dev;
 	const char *device_hint;
 	uint64_t devsize, pvsize;
-	int do_check;
+	int do_check_size, do_check_name;
+	int md_check_start;
 
 	/*
 	 * use_full_md_check: if set then no more needs to be done here,
@@ -1073,9 +1074,11 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 	 * function is looking for.
 	 */
 	if (!cmd->md_component_detection || cmd->use_full_md_check ||
-	    !strcmp(cmd->md_component_checks, "none") || !strcmp(cmd->md_component_checks, "start"))
+	    !strcmp(cmd->md_component_checks, "none"))
 		return;
 
+	md_check_start = !strcmp(cmd->md_component_checks, "start");
+
 	/*
 	 * We want to avoid extra scanning for end-of-device md superblocks
 	 * whenever possible, since it can add up to a lot of extra io if we're
@@ -1093,7 +1096,8 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 			device_hint = _get_pvsummary_device_hint(dev->pvid);
 			pvsize = _get_pvsummary_size(dev->pvid);
 			devsize = dev->size;
-			do_check = 0;
+			do_check_size = 0;
+			do_check_name = 0;
 
 			if (!devsize && !dev_get_size(dev, &devsize))
 				log_debug("No size for %s.", dev_name(dev));
@@ -1103,23 +1107,43 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd)
 			 * can be common, but not as often as PV larger.
 			 */
 			if (pvsize && devsize && (pvsize != devsize))
-				do_check = 1;
-			else if (device_hint && !strcmp(device_hint, "/dev/md"))
-				do_check = 1;
+				do_check_size = 1;
+			if (device_hint && !strncmp(device_hint, "/dev/md", 7))
+				do_check_name = 1;
+
+			if (!do_check_size && !do_check_name)
+				continue;
 
-			if (do_check) {
-				log_debug("extra md component check %llu %llu device_hint %s dev %s",
+			/*
+			 * If only the size is different (which can be fairly
+			 * common for non-md-component devs) and the user has
+			 * set "start" to disable full md checks, then skip it.
+			 * If the size is different, *and* the device name hint
+			 * looks like an md device, then it seems very likely
+			 * to be an md component, so do a full check on it even
+			 * if the user has set "start".
+			 * 
+			 * In "auto" mode, do a full check if either the size
+			 * or the name indicates a possible md component.
+			 */
+			if (do_check_size && !do_check_name && md_check_start) {
+				log_debug("extra md component check skip %llu %llu device_hint %s dev %s",
 					  (unsigned long long)pvsize, (unsigned long long)devsize,
 					  device_hint ?: "none", dev_name(dev));
+				continue;
+			}
 
-				if (dev_is_md_component(dev, NULL, 1)) {
-					log_debug("dropping PV from md component %s", dev_name(dev));
-					dev->flags &= ~DEV_SCAN_FOUND_LABEL;
-					/* lvmcache_del will also delete vginfo if info was last one */
-					lvmcache_del(info);
-					lvmcache_del_dev_from_duplicates(dev);
-					cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
-				}
+			log_debug("extra md component check %llu %llu device_hint %s dev %s",
+				  (unsigned long long)pvsize, (unsigned long long)devsize,
+				  device_hint ?: "none", dev_name(dev));
+
+			if (dev_is_md_component(dev, NULL, 1)) {
+				log_debug("dropping PV from md component %s", dev_name(dev));
+				dev->flags &= ~DEV_SCAN_FOUND_LABEL;
+				/* lvmcache_del will also delete vginfo if info was last one */
+				lvmcache_del(info);
+				lvmcache_del_dev_from_duplicates(dev);
+				cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
 			}
 		}
 	}


