From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Mon, 16 Oct 2023 19:14:19 +0000
Subject: [Git][lvmteam/lvm2][main] hints: correct fix for hints with device ids
Message-ID: <652d8b8bb30d6_2ca54c46467@gitlab-sidekiq-low-urgency-cpu-bound-v2-7c6757cf-p2t7f.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
e6c6713a by David Teigland at 2023-10-16T14:13:27-05:00
hints: correct fix for hints with device ids

Fixes commit 63b469c1609fe5d3395b7757eebaf35a4a77ea7a
&quot;device_id: fix hints with device ids&quot;

It&#39;s not correct for internal filtering to be a factor
in validating the set of devs that are the basis for hints.

Instead, look for inconsistencies between a hint entry and
the corresponding devices file entry.

- - - - -


1 changed file:

- lib/label/hints.c


Changes:

=====================================
lib/label/hints.c
=====================================
@@ -507,17 +507,6 @@ int validate_hints(struct cmd_context *cmd, struct dm_list *hints)
 		if (!(hint = _find_hint_name(hints, dev_name(dev))))
 			continue;
 
-		/*
-		 * If this dev is excluded by any filter then hints invalid.
-		 * use cmd->filter->passes_filter(cmd, cmd->filter, dev, "persistent") ?
-		 */
-		if (dev->filtered_flags) {
-			log_debug("Hints invalid for filtered %s: %s",
-				  dev_name(dev), dev_filtered_reason(dev));
-			ret = 0;
-			break;
-		}
-
 		/* The cmd hasn't needed this hint's dev so it's not been scanned. */
 		if (!hint->chosen)
 			continue;
@@ -705,8 +694,9 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	char devpath[PATH_MAX];
 	FILE *fp;
 	struct dev_iter *iter;
+	struct dev_use *du;
 	struct hint hint;
-	struct hint *alloc_hint;
+	struct hint *alloc_hint, *hp;
 	struct device *dev;
 	char *split[HINT_LINE_WORDS];
 	char *name, *pvid, *devn, *vgname, *p, *filter_str = NULL;
@@ -910,6 +900,32 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 		return 1;
 	}
 
+	/*
+	 * Check that the dev in each hint is a dev that's matched to a
+	 * devices file entry.
+	 */
+	if (cmd->enable_devices_file) {
+		dm_list_iterate_items(hp, hints) {
+			if (!(du = get_du_for_devname(cmd, hp->name))) {
+				log_debug("ignore hints: no devices file entry for %s", hp->name);
+				*needs_refresh = 1;
+				return 1;
+			}
+			if (!du->dev) {
+				log_debug("ignore hints: no device matches devices file entry for %s", hp->name);
+				*needs_refresh = 1;
+				return 1;
+			}
+			if (hp->devt != du->dev->dev) {
+				log_debug("ignore hints: devno %d:%d does not match %d:%d for %s",
+					  (int)MAJOR(hp->devt), (int)MINOR(hp->devt),
+					  (int)MAJOR(du->dev->dev), (int)MINOR(du->dev->dev), hp->name);
+				*needs_refresh = 1;
+				return 1;
+			}
+		}
+	}
+
 	log_debug("accept hints found %d", dm_list_size(hints));
 	return 1;
 }



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/e6c6713a1baeadb485e2200fd7333edd8f78a71c

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/e6c6713a1baeadb485e2200fd7333edd8f78a71c
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231016/f022b555/attachment-0001.htm>
