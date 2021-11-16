From: David Teigland <teigland@sourceware.org>
Date: Tue, 16 Nov 2021 20:34:22 +0000 (GMT)
Subject: main - device_id: searched_devnames improvements
Message-ID: <20211116203422.8297A385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c4ce4669eb8d8cacc095bd70871c13a4042e5af
Commit:        5c4ce4669eb8d8cacc095bd70871c13a4042e5af
Parent:        fee39370020424234bee1295cac480afeef72fd6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 16 11:26:41 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 16 14:29:17 2021 -0600

device_id: searched_devnames improvements

Remove the searched_devnames file in a couple more places:
. When hints need refreshing it's possible that a missing
  devices file entry could be found by searching devices
  again.
. When a devices file entry devname is first found to be
  incorrect, a new search for missing entries may be
  useful.
---
 lib/device/device_id.c | 28 ++++++++++++++++++++++++++--
 lib/label/hints.c      | 10 ++++++++++
 2 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 7bcaf3df4..b6e31d0e7 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -74,6 +74,8 @@ void unlink_searched_devnames(struct cmd_context *cmd)
 
 	if (unlink(_searched_file))
 		log_debug("unlink %s errno %d", _searched_file, errno);
+	else
+		log_debug("unlink %s", _searched_file);
 }
 
 static int _searched_devnames_exists(struct cmd_context *cmd)
@@ -779,7 +781,7 @@ static void _device_ids_update_try(struct cmd_context *cmd)
 	int held = 0;
 
 	if (cmd->expect_missing_vg_device) {
-		log_print("skip updating devices file.");
+		log_print("Devices file update skipped."); 
 		return;
 	}
 
@@ -1440,8 +1442,22 @@ static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct
 	const char *idname;
 	int part;
 
-	if (!du->idname || !du->idtype)
+	/*
+	 * The idname will be removed from an entry with devname type when the
+	 * devname is read and found to hold a different PVID than the PVID in
+	 * the entry.  At that point we only have the PVID and no known
+	 * location for it.
+	 */
+	if (!du->idname || !du->idtype) {
+		/*
+		log_debug("Mismatch device_id %s %s %s to %s",
+			  du->idtype ? idtype_to_str(du->idtype) : "idtype_missing",
+			  du->idname ? du->idname : "idname_missing",
+			  du->devname ? du->devname : "devname_missing",
+			  dev_name(dev));
+		*/
 		return 0;
+	}
 
 	/*
 	 * Some idtypes can only match devices with a specific major number,
@@ -1963,6 +1979,14 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			*device_ids_invalid = 1;
 	}
 
+	/*
+	 * When a new devname/pvid mismatch is discovered, a new search for the
+	 * pvid should be permitted (searched_devnames may exist to suppress
+	 * searching for other pvids.)
+	 */
+	if (update_file)
+		unlink_searched_devnames(cmd);
+
 	/* FIXME: for wrong devname cases, wait to write new until device_ids_find_renamed_devs? */
 
 	/*
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 9a7c280eb..93dfdd5c1 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -1397,6 +1397,16 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 		log_debug("get_hints: needs refresh");
 		free_hints(&hints_list);
 
+		/*
+		 * This is not related to hints, and is probably unnecessary,
+		 * but it could possibly help.  When hints become invalid it's
+		 * usually becaues devs on the system have changed, and that
+		 * also means that a missing devices file entry might be found
+		 * by searching devices again.  (the searched_devnames
+		 * mechanism should eventually be replaced)
+		 */
+		unlink_searched_devnames(cmd);
+
 		if (!_lock_hints(cmd, LOCK_EX, NONBLOCK))
 			return 0;
 


