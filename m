From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:18 +0000 (GMT)
Subject: master - gcc: do not use return with void function
Message-ID: <20200828195918.BFB7B386EC3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19e9c88faf10bf2f9a2dd7da695b776163fb7bd4
Commit:        19e9c88faf10bf2f9a2dd7da695b776163fb7bd4
Parent:        ee0cb17608d2e9f6d92ea339e121713312c3f84f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 19:33:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:03 2020 +0200

gcc: do not use return with void function

Follow C norm and do not use 'return' in void function to call other
functions.
---
 daemons/lvmlockd/lvmlockd-client.h |  2 +-
 lib/label/hints.c                  |  2 +-
 libdm/dm-tools/dmsetup.c           | 12 ++++++++----
 libdm/libdm-stats.c                |  6 ++++--
 4 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index 62ffb732a..1d49dded8 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -33,7 +33,7 @@ static inline daemon_handle lvmlockd_open(const char *sock)
 
 static inline void lvmlockd_close(daemon_handle h)
 {
-	return daemon_close(h);
+	daemon_close(h);
 }
 
 /*
diff --git a/lib/label/hints.c b/lib/label/hints.c
index fdc0bd6c0..3125ae01d 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -354,7 +354,7 @@ void hints_exit(struct cmd_context *cmd)
 	free_hints(&cmd->hints);
 	if (_hints_fd == -1)
 		return;
-	return _unlock_hints(cmd);
+	_unlock_hints(cmd);
 }
 
 void free_hints(struct dm_list *hints)
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index d01b8f2e8..bf2762ae7 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -6359,13 +6359,17 @@ static void _usage(FILE *out)
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
 
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 05971bdad..5379bed5e 100644
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


