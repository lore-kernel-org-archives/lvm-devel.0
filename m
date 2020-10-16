From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:49 +0000 (GMT)
Subject: stable-2.02 - gcc: do not use return with void function
Message-ID: <20201016191049.63A80396EC45@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7b4b127e9c135cff0b4603cf60b4ca94eee91f6
Commit:        f7b4b127e9c135cff0b4603cf60b4ca94eee91f6
Parent:        55a8b1bd37aefb6835d41118cf94f429e7d20519
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:33:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

gcc: do not use return with void function

Follow C norm and do not use 'return' in void function to call other
functions.
---
 daemons/lvmlockd/lvmlockd-client.h |  2 +-
 libdm/libdm-stats.c                |  6 ++++--
 tools/dmsetup.c                    | 12 ++++++++----
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index bc9059621..99aa86f94 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -32,7 +32,7 @@ static inline daemon_handle lvmlockd_open(const char *sock)
 
 static inline void lvmlockd_close(daemon_handle h)
 {
-	return daemon_close(h);
+	daemon_close(h);
 }
 
 /*
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index e46250193..f914d47c9 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1459,8 +1459,10 @@ static void _stats_walk_start(const struct dm_stats *dms, uint64_t *flags,
 	if (!dms->regions)
 		return;
 
-	if (!(*flags & (DM_STATS_WALK_AREA | DM_STATS_WALK_REGION)))
-		return _group_walk_start(dms, flags, cur_r, cur_a, cur_g);
+	if (!(*flags & (DM_STATS_WALK_AREA | DM_STATS_WALK_REGION))) {
+		_group_walk_start(dms, flags, cur_r, cur_a, cur_g);
+		return;
+	}
 
 	/* initialise cursor state */
 	*cur_a = 0;
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b5419ca97..8837826e9 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -6356,13 +6356,17 @@ static void _usage(FILE *out)
 {
 	switch (_base_commands[_base_command].type) {
 	case DMSETUP_TYPE:
-		return _dmsetup_usage(out);
+		_dmsetup_usage(out);
+		break;
 	case LOSETUP_TYPE:
-		return _losetup_usage(out);
+		_losetup_usage(out);
+		break;
 	case STATS_TYPE:
-		return _stats_usage(out);
+		_stats_usage(out);
+		break;
 	case DEVMAP_NAME_TYPE:
-		return _devmap_name_usage(out);
+		_devmap_name_usage(out);
+		break;
 	}
 }
 


