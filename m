From: David Teigland <teigland@sourceware.org>
Date: Tue, 31 Jan 2023 21:30:54 +0000 (GMT)
Subject: main - pvscan: use alternate device names from DEVLINKS to check filter
Message-ID: <20230131213054.202F63858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17a3585cbb55d9a15ced9775a18b50c53a50ee8e
Commit:        17a3585cbb55d9a15ced9775a18b50c53a50ee8e
Parent:        d9f8acb65a78c20ac806efaeb7a1e39208e1a443
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 19 17:37:31 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 31 15:30:35 2023 -0600

pvscan: use alternate device names from DEVLINKS to check filter

pvscan --cache <dev> is called by our udev rule at a time when all
the symlinks for <dev> may not be created yet (by other udev rules.)
The regex filter in lvm.conf may refer to <dev> using a symlink name
that hasn't yet been created, which would cause <dev> to not match
the filter regex.  The DEVLINKS env var, set by udev, contains all
the symlink names for <dev> that have been or will be created.
So, we add all these symlink names to dev->aliases, as if we had
found them in /dev.  This allows <dev> to be recognized by a regex
filter containing a symlink for <dev>.
---
 lib/commands/toolcontext.h   |  1 +
 lib/filters/filter-regex.c   |  2 +-
 man/lvmautoactivation.7_main | 13 ++++++++++
 tools/pvscan.c               | 60 ++++++++++++++++++++++++++------------------
 4 files changed, 51 insertions(+), 25 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 7f5fd12fc..4069b6116 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -207,6 +207,7 @@ struct cmd_context {
 	unsigned udevoutput:1;
 	unsigned online_vg_file_removed:1;
 	unsigned disable_dm_devs:1;		/* temporarily disable use of dm devs cache */
+	unsigned filter_regex_set_preferred_name_disable:1; /* prevent dev_set_preferred_name */
 
 	/*
 	 * Devices and filtering.
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 05c5b3f2d..d9ed0104c 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -179,7 +179,7 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 
 		if (m >= 0) {
 			if (dm_bit(rf->accept, m)) {
-				if (!first)
+				if (!first && !cmd->filter_regex_set_preferred_name_disable)
 					dev_set_preferred_name(sl, dev);
 
 				return 1;
diff --git a/man/lvmautoactivation.7_main b/man/lvmautoactivation.7_main
index 808ea0d9f..0f7734557 100644
--- a/man/lvmautoactivation.7_main
+++ b/man/lvmautoactivation.7_main
@@ -184,6 +184,19 @@ system from booting.  A custom systemd service could be written to run
 autoactivation during system startup, in which case disabling event
 autoactivation may be useful.
 .
+.SS lvm.conf filter
+.P
+Device symlinks from /dev/disk/ can be used in the lvm.conf filter to
+guard against changes in kernel device names. The /dev/disk/by-path/ or
+/dev/disk/by-id/ prefixes should be included in the filter names; these
+prefixes help lvm detect that symlink names are used. Filters containing
+symlinks require special matching by commands run in the lvm udev rule.
+.P
+Common symlinks, e.g. beginning with wwn-, scsi-, pci-, or lvm-pv-uuid-,
+are recommended.  Uncommon or custom symlinks created by custom udev rules
+may be less reliable. If a custom udev rule creates symlinks used in the
+lvm filter, then the udev rule should be started prior to the lvm rule.
+.
 .SH EXAMPLES
 .P
 VG "vg" contains two PVs:
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 773862227..71485610b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -910,30 +910,6 @@ static int _get_args_devs(struct cmd_context *cmd, struct dm_list *pvscan_args,
 	struct pvscan_arg *arg;
 	struct device_list *devl;
 
-	/*
-	 * If no devices file is used, and lvm.conf filter is set to
-	 * accept /dev/disk/by-id/lvm-pv-uuid-xyz or another symlink,
-	 * but pvscan --cache is passed devname or major:minor, so
-	 * pvscan needs to match its arg device to the filter symlink.
-	 * setup_dev_in_dev_cache() adds /dev/sda2 to dev-cache which
-	 * does not match a symlink to /dev/sda2, so we need a full
-	 * dev_cache_scan that will associate all symlinks to sda2,
-	 * which allows filter-regex to work.  This case could be
-	 * optimized if needed by adding dev-cache entries for each
-	 * filter "a" entry (filter symlink patterns would still need
-	 * a full dev_cache_scan.)
-	 * (When no devices file is used and 69-dm-lvm.rules is
-	 * used which calls pvscan directly, symlinks may not
-	 * have been created by other rules when pvscan runs, so
-	 * the full dev_cache_scan may still not find them.)
-	 */
-	if (!cmd->enable_devices_file && !cmd->enable_devices_list &&
-	    (_filter_uses_symlinks(cmd, devices_filter_CFG) ||
-	     _filter_uses_symlinks(cmd, devices_global_filter_CFG))) {
-		log_print_pvscan(cmd, "finding all devices for filter symlinks.");
-		dev_cache_scan(cmd);
-	}
-
 	/* pass NULL filter when getting devs from dev-cache, filtering is done separately */
 
 	/* in common usage, no dev will be found for a devno */
@@ -1550,6 +1526,42 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 	cmd->filter_nodata_only = 1;
 
+	/*
+	 * Hack to handle regex filter that contains a symlink name for dev arg.
+	 * pvscan --cache <dev> is called by our udev rule at a time when the
+	 * symlinks for <dev> may not all be created yet (by other udev rules.)
+	 * The regex filter in lvm.conf may refer to <dev> using a symlink name,
+	 * so we need to know all the symlinks for <dev> in order for the filter
+	 * to work correctly. Scanning /dev with dev_cache_scan() would usually
+	 * find all the symlink names for <dev>, adding them to dev->aliases,
+	 * which would let the filter work, but all symlinks aren't created yet.
+	 * But, the DEVLINKS env var, set by udev, contains all the symlink
+	 * names for <dev> that have been or *will be* created. So, we add all
+	 * these symlink names to dev->aliases, as if we had found them in /dev.
+	 * This allows <dev> to be recognized by a regex filter containing a
+	 * symlink for <dev>. We have to tell filter-regex to not set the
+	 * preferred name for <dev> to a symlink name since the <dev> may not
+	 * be usable by that symlink name yet.
+	 */
+	if ((dm_list_size(&pvscan_devs) == 1) &&
+	    !cmd->enable_devices_file && !cmd->enable_devices_list &&
+	    (_filter_uses_symlinks(cmd, devices_filter_CFG) ||
+	     _filter_uses_symlinks(cmd, devices_global_filter_CFG))) {
+		char *env_str;
+		struct dm_list *env_aliases;
+		devl = dm_list_item(dm_list_first(&pvscan_devs), struct device_list);
+		if ((env_str = getenv("DEVLINKS"))) {
+			log_debug("Finding symlink names from DEVLINKS for filter regex.");
+			log_debug("DEVLINKS %s", env_str);
+			env_aliases = str_to_str_list(cmd->mem, env_str, " ", 0);
+			dm_list_splice(&devl->dev->aliases, env_aliases);
+		} else {
+			log_debug("Finding symlink names from /dev for filter regex.");
+			dev_cache_scan(cmd);
+		}
+		cmd->filter_regex_set_preferred_name_disable = 1;
+	}
+
 	dm_list_iterate_items_safe(devl, devl2, &pvscan_devs) {
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
 			log_print_pvscan(cmd, "%s excluded: %s.",

