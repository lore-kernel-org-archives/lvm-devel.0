From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:27 +0000 (GMT)
Subject: main - cov: pvck fix memleak
Message-ID: <20210727225027.4EF8E385040A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=01081b21006abe4d9a0102541982cb0fcaeb22dc
Commit:        01081b21006abe4d9a0102541982cb0fcaeb22dc
Parent:        8ebcbe9ace6e5c88a35cf62cd04b853ca7551a2b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 22:52:08 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:22 2021 +0200

cov: pvck fix memleak

Fix memory leaks on error paths for allocated
path and backup_file name by converting allocation to
dm_pool_alloc  and also change devicefile structure to contain
embeded  path as last struct member - so we could allocate
only needed string size  instead of PATH_MAX from pool.

TODO: still to be fixed 'mf' struct.
---
 tools/pvck.c | 23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 4e8814737..d81966966 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -343,14 +343,15 @@ static uint64_t mda2_size_from_offset(struct device *dev, uint64_t mda2_offset)
 }
 
 struct devicefile {
-	char path[PATH_MAX];
 	int fd;
+	char path[0];
 };
 
-static struct devicefile *get_devicefile(const char *path)
+static struct devicefile *get_devicefile(struct cmd_context *cmd, const char *path)
 {
 	struct stat sb;
 	struct devicefile *def;
+	size_t len;
 
 	if (stat(path, &sb))
 		return_NULL;
@@ -358,18 +359,14 @@ static struct devicefile *get_devicefile(const char *path)
 	if ((sb.st_mode & S_IFMT) != S_IFREG)
 		return_NULL;
 
-	if (!(def = malloc(sizeof(struct devicefile))))
+	len = strlen(path) + 1;
+	if (!(def = dm_pool_alloc(cmd->mem, sizeof(struct devicefile) + len)))
 		return_NULL;
 
-	if (dm_snprintf(def->path, PATH_MAX, "%s", path) < 0) {
-		free(def);
-		return_NULL;
-	}
+	memcpy(def->path, path, len);
 
-	if ((def->fd = open(path, O_RDONLY)) < 0) {
-		free(def);
+	if ((def->fd = open(path, O_RDONLY)) < 0)
 		return_NULL;
-	}
 
 	return def;
 }
@@ -1774,8 +1771,7 @@ static int _get_one_setting(struct cmd_context *cmd, struct settings *set, char
 	}
 
 	if (!strncmp(key, "backup_file", strlen("backup_file"))) {
-		free(set->backup_file);
-		if ((set->backup_file = strdup(val)))
+		if ((set->backup_file = dm_pool_strdup(cmd->mem, val)))
 			return 1;
 		return 0;
 	}
@@ -3063,7 +3059,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 			return ECMD_FAILED;
 		}
 		if (S_ISREG(sb.st_mode))
-			def = get_devicefile(pv_name);
+			def = get_devicefile(cmd, pv_name);
 		else if (S_ISBLK(sb.st_mode)) {
 			if (!setup_device(cmd, pv_name)) {
 				log_error("Failed to set up device %s.", pv_name);
@@ -3145,7 +3141,6 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		} else
 			log_error("Unknown dump value.");
 
-		free(def);
 		if (!ret)
 			return ECMD_FAILED;
 		return ECMD_PROCESSED;


