From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:29 -0500
Subject: stable-2.02 - cov: remove unused assigns
Message-ID: <201903051353.x25DrTSR006747@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a93699ece9dfebe5dfa8a7c8008b12bdecf037c9
Commit:        a93699ece9dfebe5dfa8a7c8008b12bdecf037c9
Parent:        e4bb94a93e9cda695717093024800f637aead51c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 3 16:48:20 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:28:31 2019 +0100

cov: remove unused assigns

(cherry picked from commit 70e3d0a613fb53e52f7a7cb31d65bcc2fa7ab738)

Conflicts:
	tools/pvscan.c
	tools/vgchange.c
---
 daemons/dmfilemapd/dmfilemapd.c |    4 ++--
 lib/device/dev-cache.c          |    3 +--
 lib/metadata/metadata.c         |    6 ++----
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 7519799..79ddf18 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -629,10 +629,10 @@ check_unlinked:
 
 static int _daemonise(struct filemap_monitor *fm)
 {
-	pid_t pid = 0, sid;
+	pid_t pid = 0;
 	int fd;
 
-	if (!(sid = setsid())) {
+	if (!setsid()) {
 		_early_log("setsid failed.");
 		return 0;
 	}
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index c866ff9..997d75f 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -667,10 +667,9 @@ struct dm_list *dev_cache_get_dev_list_for_lvid(const char *lvid)
 
 void dev_cache_failed_path(struct device *dev, const char *path)
 {
-	struct device *dev_by_path;
 	struct dm_str_list *strl;
 
-	if ((dev_by_path = (struct device *) dm_hash_lookup(_cache.names, path)))
+	if (dm_hash_lookup(_cache.names, path))
 		dm_hash_remove(_cache.names, path);
 
 	dm_list_iterate_items(strl, &dev->aliases) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2292568..cb38f66 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1720,15 +1720,13 @@ struct generic_logical_volume *find_historical_glv(const struct volume_group *vg
 
 int lv_name_is_used_in_vg(const struct volume_group *vg, const char *name, int *historical)
 {
-	struct generic_logical_volume *historical_lv;
-	struct logical_volume *lv;
 	int found = 0;
 
-	if ((lv = find_lv(vg, name))) {
+	if (find_lv(vg, name)) {
 		found = 1;
 		if (historical)
 			*historical = 0;
-	} else if ((historical_lv = find_historical_glv(vg, name, 0, NULL))) {
+	} else if (find_historical_glv(vg, name, 0, NULL)) {
 		found = 1;
 		if (historical)
 			*historical = 1;


