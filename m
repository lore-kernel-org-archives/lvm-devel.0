From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 7 Dec 2017 15:03:36 -0500
Subject: master - thin: always clear memory before parsing status
Message-ID: <201712072003.vB7K3at9005574@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2208ebfe16e5b5cd54c762a5a06edd0681d62fa9
Commit:        2208ebfe16e5b5cd54c762a5a06edd0681d62fa9
Parent:        2166d7be72c7371f0f94934625252646c5164a2c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 6 13:24:41 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 7 20:59:28 2017 +0100

thin: always clear memory before parsing status

Ensure there cannot be 'reused' any data from some previous call.
---
 WHATS_NEW             |    1 +
 libdm/libdm-deptree.c |    2 +-
 libdm/libdm-targets.c |    4 +++-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a5ec3e7..4659d55 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Ensure _node_send_message always uses clean status of thin pool.
   Fix lvmlockd to use pool lock when accessing _tmeta volume.
   Report expected sanlock_convert errors only when retries fail.
   Avoid blocking in sanlock_convert on SH to EX lock conversion.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 34a1547..b844a57 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1493,7 +1493,7 @@ static int _node_send_messages(struct dm_tree_node *dnode,
 {
 	struct load_segment *seg;
 	struct thin_message *tmsg;
-	struct dm_status_thin_pool stp = { 0 };
+	struct dm_status_thin_pool stp;
 	const char *uuid;
 	int have_messages;
 
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 6577f07..990d275 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -350,6 +350,8 @@ int parse_thin_pool_status(const char *params, struct dm_status_thin_pool *s)
 {
 	int pos;
 
+	memset(s, 0, sizeof(*s));
+
 	if (!params) {
 		log_error("Failed to parse invalid thin params.");
 		return 0;
@@ -406,7 +408,7 @@ int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 {
 	struct dm_status_thin_pool *s;
 
-	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin_pool)))) {
+	if (!(s = dm_pool_alloc(mem, sizeof(struct dm_status_thin_pool)))) {
 		log_error("Failed to allocate thin_pool status structure.");
 		return 0;
 	}


