From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:57 +0000 (UTC)
Subject: master - cleanup: use DM_ARRAY_SIZE
Message-ID: <20140408090257.C511A60F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5553a099d1a6f0c8e3421712517d41ef820a5964
Commit:        5553a099d1a6f0c8e3421712517d41ef820a5964
Parent:        56175f6ba96d161a1d8f70bf985d95066b41d2d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:10:30 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:15 2014 +0200

cleanup: use DM_ARRAY_SIZE

More use of libdevmapper macro
---
 daemons/dmeventd/dmeventd.c      |    2 +-
 lib/display/display.c            |    2 +-
 lib/metadata/metadata.c          |    2 +-
 lib/mm/memlock.c                 |    4 ++--
 lib/raid/raid.c                  |    2 +-
 lib/thin/thin.c                  |    8 ++++----
 libdm/ioctl/libdm-iface.c        |    3 +--
 tools/lvcreate.c                 |    2 +-
 unit-tests/datastruct/bitset_t.c |    2 +-
 9 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index f4f09b8..af7a2e4 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1479,7 +1479,7 @@ static int _handle_request(struct dm_event_daemon_message *msg,
 		{ DM_EVENT_CMD_GET_PARAMETERS, _get_parameters},
 	}, *req;
 
-	for (req = requests; req < requests + sizeof(requests) / sizeof(struct request); req++)
+	for (req = requests; req < requests + DM_ARRAY_SIZE(requests); ++req)
 		if (req->cmd == msg->cmd)
 			return req->f(message_data);
 
diff --git a/lib/display/display.c b/lib/display/display.c
index 1846f90..810097a 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -41,7 +41,7 @@ static const struct {
 	ALLOC_INHERIT, "inherit", 'i'}
 };
 
-static const int _num_policies = sizeof(_policies) / sizeof(*_policies);
+static const int _num_policies = DM_ARRAY_SIZE(_policies);
 
 /* Test if the doubles are close enough to be considered equal */
 static int _close_enough(double d1, double d2)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 65a288c..643613f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2027,7 +2027,7 @@ static int _lv_each_dependency(struct logical_volume *lv,
 		(lv->rdevice && lv != lv->rdevice->slog) ? lv->rdevice->slog : 0,
 		lv->snapshot ? lv->snapshot->origin : 0,
 		lv->snapshot ? lv->snapshot->cow : 0 };
-	for (i = 0; i < sizeof(deps) / sizeof(*deps); ++i) {
+	for (i = 0; i < DM_ARRAY_SIZE(deps); ++i) {
 		if (deps[i] && !fn(deps[i], data))
 			return_0;
 	}
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 70af07e..c08b0eb 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -176,7 +176,7 @@ static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 	}
 
 	/* always ignored areas */
-	for (i = 0; i < sizeof(_ignore_maps) / sizeof(_ignore_maps[0]); ++i)
+	for (i = 0; i < DM_ARRAY_SIZE(_ignore_maps); ++i)
 		if (strstr(line + pos, _ignore_maps[i])) {
 			log_debug_mem("%s ignore filter '%s' matches '%s': Skipping.",
 				      lock_str, _ignore_maps[i], line);
@@ -186,7 +186,7 @@ static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 	sz = to - from;
 	if (!cn) {
 		/* If no blacklist configured, use an internal set */
-		for (i = 0; i < sizeof(_blacklist_maps) / sizeof(_blacklist_maps[0]); ++i)
+		for (i = 0; i < DM_ARRAY_SIZE(_blacklist_maps); ++i)
 			if (strstr(line + pos, _blacklist_maps[i])) {
 				log_debug_mem("%s default filter '%s' matches '%s': Skipping.",
 					      lock_str, _blacklist_maps[i], line);
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index e592573..0869ff4 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -352,7 +352,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 			return 0;
 		}
 
-		for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
+		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
 			if ((maj > _features[i].maj) ||
 			    (maj == _features[i].maj && min >= _features[i].min))
 				_raid_attrs |= _features[i].raid_feature;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index ff4eafd..d4bde8b 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -653,7 +653,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 			return 0;
 		}
 
-		for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
+		for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
 			if ((maj > _features[i].maj) ||
 			    (maj == _features[i].maj && min >= _features[i].min))
 				_attrs |= _features[i].thin_feature;
@@ -678,13 +678,13 @@ static int _thin_target_present(struct cmd_context *cmd,
 					str = cv->v.str;
 					if (!*str)
 						continue;
-					for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
+					for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
 						if (strcasecmp(str, _features[i].feature) == 0)
 							_feature_mask |= _features[i].thin_feature;
 				}
 			}
 			_feature_mask = ~_feature_mask;
-			for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
+			for (i = 0; i < DM_ARRAY_SIZE(_features); ++i)
 				if ((_attrs & _features[i].thin_feature) &&
 				    !(_feature_mask & _features[i].thin_feature))
 					log_very_verbose("Target %s %s support disabled by %s",
@@ -757,7 +757,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 	struct segment_type *segtype;
 	unsigned i;
 
-	for (i = 0; i < sizeof(reg_segtypes)/sizeof(reg_segtypes[0]); ++i) {
+	for (i = 0; i < DM_ARRAY_SIZE(reg_segtypes); ++i) {
 		segtype = dm_zalloc(sizeof(*segtype));
 
 		if (!segtype) {
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 25f1d90..73cda17 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1822,8 +1822,7 @@ int dm_task_run(struct dm_task *dmt)
 	const char *dev_name = DEV_NAME(dmt);
 	const char *dev_uuid = DEV_UUID(dmt);
 
-	if ((unsigned) dmt->type >=
-	    (sizeof(_cmd_data_v4) / sizeof(*_cmd_data_v4))) {
+	if ((unsigned) dmt->type >= DM_ARRAY_SIZE(_cmd_data_v4)) {
 		log_error(INTERNAL_ERROR "unknown device-mapper task %d",
 			  dmt->type);
 		return 0;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index c612465..6a9264a 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1135,7 +1135,7 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 			zero_ARG
 		};
 
-		for (i = 0; i < sizeof(_argname)/sizeof(_argname[0]); ++i) {
+		for (i = 0; i < DM_ARRAY_SIZE(_argname); ++i) {
 			if (arg_count(vg->cmd, _argname[i])) {
 				log_error("%s is only available for thin pool creation.",
 					  arg_long_option_name(_argname[i]));
diff --git a/unit-tests/datastruct/bitset_t.c b/unit-tests/datastruct/bitset_t.c
index 83b297b..93deb5a 100644
--- a/unit-tests/datastruct/bitset_t.c
+++ b/unit-tests/datastruct/bitset_t.c
@@ -121,7 +121,7 @@ int main(int argc, char **argv)
         };
 
         int i;
-        for (i = 0; i < sizeof(tests) / sizeof(*tests); i++) {
+        for (i = 0; i < DM_ARRAY_SIZE(tests); ++i) {
                 struct dm_pool *mem = dm_pool_create("bitset test", 1024);
                 assert(mem);
                 tests[i](mem);


