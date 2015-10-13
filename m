From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:09 +0000 (UTC)
Subject: master - cleanup: avoid using private
Message-ID: <20151013140409.70F94602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a633750f1e43aa655e5e6e05269aeab8650f55d
Commit:        0a633750f1e43aa655e5e6e05269aeab8650f55d
Parent:        0e2261dbd1d489dff158fce88a705a680aaaa3da
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 12 11:40:51 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:22:58 2015 +0200

cleanup: avoid using private

Switch private to user.
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |    6 +++---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c      |    6 +++---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |   12 ++++++------
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |   12 ++++++------
 4 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index c010794..d418b08 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -156,7 +156,7 @@ static int _remove_failed_devices(const char *device)
 
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
-		   void **unused __attribute__((unused)))
+		   void **user)
 {
 	void *next = NULL;
 	uint64_t start, length;
@@ -215,7 +215,7 @@ int register_device(const char *device,
 		    const char *uuid __attribute__((unused)),
 		    int major __attribute__((unused)),
 		    int minor __attribute__((unused)),
-		    void **unused __attribute__((unused)))
+		    void **user)
 {
 	if (!dmeventd_lvm2_init())
 		return 0;
@@ -229,7 +229,7 @@ int unregister_device(const char *device,
 		      const char *uuid __attribute__((unused)),
 		      int major __attribute__((unused)),
 		      int minor __attribute__((unused)),
-		      void **unused __attribute__((unused)))
+		      void **user)
 {
 	log_info("No longer monitoring mirror device %s for events.",
 		 device);
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 822d7c4..6522556 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -116,7 +116,7 @@ static int _process_raid_event(char *params, const char *device)
 
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
-		   void **unused __attribute__((unused)))
+		   void **user)
 {
 	void *next = NULL;
 	uint64_t start, length;
@@ -152,7 +152,7 @@ int register_device(const char *device,
 		    const char *uuid __attribute__((unused)),
 		    int major __attribute__((unused)),
 		    int minor __attribute__((unused)),
-		    void **unused __attribute__((unused)))
+		    void **user)
 {
 	if (!dmeventd_lvm2_init())
 		return 0;
@@ -166,7 +166,7 @@ int unregister_device(const char *device,
 		      const char *uuid __attribute__((unused)),
 		      int major __attribute__((unused)),
 		      int minor __attribute__((unused)),
-		      void **unused __attribute__((unused)))
+		      void **user)
 {
 	log_info("No longer monitoring RAID device %s for events.",
 		 device);
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index ae8e308..8d5bce1 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -126,8 +126,9 @@ static void _umount(const char *device, int major, int minor)
 
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
-		   void **private)
+		   void **user)
 {
+	struct dso_state *state = *user;
 	void *next = NULL;
 	uint64_t start, length;
 	char *target_type = NULL;
@@ -135,7 +136,6 @@ void process_event(struct dm_task *dmt,
 	struct dm_status_snapshot *status = NULL;
 	const char *device = dm_task_get_name(dmt);
 	int percent;
-	struct dso_state *state = *private;
 
 	/* No longer monitoring, waiting for remove */
 	if (!state->percent_check)
@@ -199,7 +199,7 @@ int register_device(const char *device,
 		    const char *uuid __attribute__((unused)),
 		    int major __attribute__((unused)),
 		    int minor __attribute__((unused)),
-		    void **private)
+		    void **user)
 {
 	struct dm_pool *statemem = NULL;
 	struct dso_state *state;
@@ -218,7 +218,7 @@ int register_device(const char *device,
 
 	state->mem = statemem;
 	state->percent_check = CHECK_MINIMUM;
-	*private = state;
+	*user = state;
 
 	log_info("Monitoring snapshot %s.", device);
 
@@ -237,9 +237,9 @@ int unregister_device(const char *device,
 		      const char *uuid __attribute__((unused)),
 		      int major __attribute__((unused)),
 		      int minor __attribute__((unused)),
-		      void **private)
+		      void **user)
 {
-	struct dso_state *state = *private;
+	struct dso_state *state = *user;
 
 	log_info("No longer monitoring snapshot %s.", device);
 	dm_pool_destroy(state->mem);
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index f57eb9b..0801adf 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -251,11 +251,11 @@ out:
 
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
-		   void **private)
+		   void **user)
 {
 	const char *device = dm_task_get_name(dmt);
 	int percent;
-	struct dso_state *state = *private;
+	struct dso_state *state = *user;
 	struct dm_status_thin_pool *tps = NULL;
 	void *next = NULL;
 	uint64_t start, length;
@@ -351,7 +351,7 @@ int register_device(const char *device,
 		    const char *uuid __attribute__((unused)),
 		    int major __attribute__((unused)),
 		    int minor __attribute__((unused)),
-		    void **private)
+		    void **user)
 {
 	struct dm_pool *statemem = NULL;
 	struct dso_state *state;
@@ -374,7 +374,7 @@ int register_device(const char *device,
 	state->mem = statemem;
 	state->metadata_percent_check = CHECK_MINIMUM;
 	state->data_percent_check = CHECK_MINIMUM;
-	*private = state;
+	*user = state;
 
 	log_info("Monitoring thin %s.", device);
 
@@ -389,9 +389,9 @@ int unregister_device(const char *device,
 		      const char *uuid __attribute__((unused)),
 		      int major __attribute__((unused)),
 		      int minor __attribute__((unused)),
-		      void **private)
+		      void **user)
 {
-	struct dso_state *state = *private;
+	struct dso_state *state = *user;
 
 	log_info("No longer monitoring thin %s.", device);
 	dm_pool_destroy(state->mem);


