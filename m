From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:37 +0000 (UTC)
Subject: dev-prajnoha-selout - cleanup: cosmetics.
Message-ID: <20140509065637.47ABF60774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3e68c8a71c3bc36135d73cd8028cec56eca5cb2
Commit:        d3e68c8a71c3bc36135d73cd8028cec56eca5cb2
Parent:        d88fab8d3a64cb492c808a50d247686febedc9e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 11:44:33 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:17:46 2014 +0200

cleanup: cosmetics.

Initialized attrs so analyzers are less confused
(since currently our method calls should always initialize attrs on
return).
---
 lib/metadata/snapshot_manip.c |    2 +-
 libdm/libdm-common.c          |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index a0a3e3c..5df0f98 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -41,7 +41,7 @@ int lv_is_cow(const struct logical_volume *lv)
 static uint64_t _cow_extra_chunks(struct cmd_context *cmd, uint64_t n_chunks)
 {
 	const struct segment_type *segtype;
-	unsigned attrs;
+	unsigned attrs = 0;
 
 	if (activation() &&
 	    (segtype = get_segtype_from_string(cmd, "snapshot")) &&
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index f404c63..bb793e3 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1907,7 +1907,8 @@ static int _device_has_mounted_fs(char *buffer, unsigned major, unsigned minor,
 	char kernel_dev_name[PATH_MAX];
 
 	if ((major == data->maj) && (minor == data->min)) {
-		if (!dm_device_get_name(major, minor, 1, kernel_dev_name, PATH_MAX)) {
+		if (!dm_device_get_name(major, minor, 1, kernel_dev_name,
+					sizeof(kernel_dev_name))) {
 			stack;
 			*kernel_dev_name = '\0';
 		}


