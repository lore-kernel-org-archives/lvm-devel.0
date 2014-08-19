From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:19:02 +0000 (UTC)
Subject: master - cleanup: avoid double assign
Message-ID: <20140819141902.00D4D6030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24df01f7352e0cf525528000c2026a9a6571b733
Commit:        24df01f7352e0cf525528000c2026a9a6571b733
Parent:        94786a3bbf0b68883a2618c9bc25fc88e367f9f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 19 14:19:11 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:06 2014 +0200

cleanup: avoid double assign

Skip setting a value to a variable which is never
used and overwritten/set afterwards.
---
 lib/activate/activate.c          |    2 +-
 lib/display/display.c            |    2 +-
 lib/locking/cluster_locking.c    |    2 +-
 lib/misc/lvm-flock.c             |    2 +-
 libdaemon/server/daemon-server.c |    2 +-
 libdm/libdm-report.c             |    2 +-
 tools/dmsetup.c                  |    2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1230c9a..9a4a1c3 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2325,7 +2325,7 @@ int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exc
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)
 {
-	int r = 1;
+	int r;
 
 	if (!lv) {
 		r = dm_mknodes(NULL);
diff --git a/lib/display/display.c b/lib/display/display.c
index cfd83c9..6cdd07b 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -113,7 +113,7 @@ static const char *_display_size(const struct cmd_context *cmd,
 {
 	unsigned base = BASE_UNKNOWN;
 	unsigned s;
-	int suffix = 1, precision;
+	int suffix, precision;
 	uint64_t byte = UINT64_C(0);
 	uint64_t units = UINT64_C(1024);
 	char *size_buf = NULL;
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 8070014..0a11262 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -419,7 +419,7 @@ static int _lock_resource(struct cmd_context *cmd, const char *resource,
 	char lockname[PATH_MAX];
 	int clvmd_cmd = 0;
 	const char *lock_scope;
-	const char *lock_type = "";
+	const char *lock_type;
 
 	assert(strlen(resource) < sizeof(lockname));
 	assert(resource);
diff --git a/lib/misc/lvm-flock.c b/lib/misc/lvm-flock.c
index 8b70a0c..252fec3 100644
--- a/lib/misc/lvm-flock.c
+++ b/lib/misc/lvm-flock.c
@@ -93,7 +93,7 @@ void release_flocks(int unlock)
 
 static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock)
 {
-	int r = 1;
+	int r;
 	int old_errno;
 	struct stat buf1, buf2;
 
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 3b390a3..a8afcc1 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -205,7 +205,7 @@ out:
 
 static int _open_socket(daemon_state s)
 {
-	int fd = -1;
+	int fd;
 	int file_created = 0;
 	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
 	struct stat buf;
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 9363a92..155ac60 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1278,7 +1278,7 @@ static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *v
 					     const struct selection_str_list *sel)
 {
 	struct dm_str_list *sel_item;
-	unsigned int i = 1, last_found = 1;;
+	unsigned int i, last_found = 1;;
 	int r = 0;
 
 	/* if value has no items and selection has@leas one, it's clear there's no match */
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8f64bfc..6cbd21c 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -897,7 +897,7 @@ static int _setgeometry(CMD_ARGS)
 static int _splitname(CMD_ARGS)
 {
 	struct dmsetup_report_obj obj;
-	int r = 1;
+	int r;
 
 	obj.task = NULL;
 	obj.info = NULL;


