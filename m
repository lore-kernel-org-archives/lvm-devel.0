From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:40 +0000 (GMT)
Subject: main - pvscan: enhance _count_pvid_files_from_lookup_file
Message-ID: <20210201114740.BF4A93836C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9fd207192fe81c1f89ca265c1fe0bcc54335694
Commit:        a9fd207192fe81c1f89ca265c1fe0bcc54335694
Parent:        3acf6040b558a121d918a478859ae0c97a679047
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 22:27:05 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:13:49 2021 +0100

pvscan: enhance _count_pvid_files_from_lookup_file

Ensure all vars are always properly defined in all paths.
---
 tools/pvck.c   |  2 +-
 tools/pvscan.c | 56 +++++++++++++++++++++++++-------------------------------
 2 files changed, 26 insertions(+), 32 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 88350de8c..c02ccb9f7 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3015,7 +3015,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	struct device *dev = NULL;
 	struct devicefile *def = NULL;
 	const char *dump, *repair;
-	const char *pv_name;
+	const char *pv_name = "";
 	uint64_t labelsector = 1;
 	int bad = 0;
 	int ret = 0;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 021ec691e..45d94c21b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -517,14 +517,13 @@ static int _lookup_file_contains_pvid(FILE *fp, char *pvid)
 static void _lookup_file_count_pvid_files(FILE *fp, const char *vgname, int *pvs_online, int *pvs_offline)
 {
 	char line[64];
-	char pvid[ID_LEN+1];
+	char pvid[ID_LEN+1] = { 0 };
 
 	log_debug("checking all pvid files using lookup file for %s", vgname);
 
 	rewind(fp);
 
 	while (fgets(line, sizeof(line), fp)) {
-		memset(pvid, 0, sizeof(pvid));
 		memcpy(pvid, line, ID_LEN);
 
 		if (strlen(pvid) != ID_LEN) {
@@ -583,65 +582,60 @@ static int _count_pvid_files_from_lookup_file(struct cmd_context *cmd, struct de
 					       int *pvs_online, int *pvs_offline,
 					       const char **vgname_out)
 {
-	char path[PATH_MAX];
+	char path[PATH_MAX] = { 0 };
 	FILE *fp;
 	DIR *dir;
 	struct dirent *de;
 	const char *vgname = NULL;
-	int online = 0, offline = 0;
 
+	*vgname_out = NULL;
 	*pvs_online = 0;
 	*pvs_offline = 0;
 
-	if (!(dir = opendir(_pvs_lookup_dir)))
-		goto_bad;
+	if (!(dir = opendir(_pvs_lookup_dir))) {
+		log_sys_debug("opendir", _pvs_lookup_dir);
+		return 0;
+	}
 
 	/*
 	 * Read each file in pvs_lookup to find dev->pvid, and if it's
 	 * found save the vgname of the file it's found in.
 	 */
-	while ((de = readdir(dir))) {
+	while (!vgname && (de = readdir(dir))) {
 		if (de->d_name[0] == '.')
 			continue;
 
-		memset(path, 0, sizeof(path));
-		snprintf(path, sizeof(path), "%s/%s", _pvs_lookup_dir, de->d_name);
+		if (dm_snprintf(path, sizeof(path), "%s/%s", _pvs_lookup_dir, de->d_name) < 0) {
+			log_warn("WARNING: Path %s/%s is too long.", _pvs_lookup_dir, de->d_name);
+			continue;
+		}
 
 		if (!(fp = fopen(path, "r"))) {
-			log_warn("Failed to open %s", path);
+			log_warn("WARNING: Failed to open %s.", path);
 			continue;
 		}
 
 		if (_lookup_file_contains_pvid(fp, dev->pvid)) {
-			vgname = dm_pool_strdup(cmd->mem, de->d_name);
-			break;
+			if ((vgname = dm_pool_strdup(cmd->mem, de->d_name)))
+				/*
+				 * stat pvid online file of each pvid listed in this file
+				 * the list of pvids from the file is the alternative to
+				 * using vg->pvs
+				 */
+				_lookup_file_count_pvid_files(fp, vgname, pvs_online, pvs_offline);
+			else
+				log_warn("WARNING: Failed to strdup vgname.");
 		}
 
 		if (fclose(fp))
-			stack;
+			log_sys_debug("fclose", path);
 	}
 	if (closedir(dir))
 		log_sys_debug("closedir", _pvs_lookup_dir);
 
-	if (!vgname)
-		goto_bad;
-
-	/*
-	 * stat pvid online file of each pvid listed in this file
-	 * the list of pvids from the file is the alternative to
-	 * using vg->pvs
-	 */
-	_lookup_file_count_pvid_files(fp, vgname, &online, &offline);
-
-	if (fclose(fp))
-		stack;
-
-	*pvs_online = online;
-	*pvs_offline = offline;
 	*vgname_out = vgname;
-	return 1;
-bad:
-	return 0;
+
+	return (vgname) ? 1 : 0;
 }
 
 static void _online_dir_setup(void)


