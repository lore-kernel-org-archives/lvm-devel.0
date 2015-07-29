From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 29 Jul 2015 19:49:12 +0000 (UTC)
Subject: master - vgcreate: improve checks for existing global lock
Message-ID: <20150729194912.7F87660DD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=772b54a08bae19f59d93ca456691e3ce3cbb00da
Commit:        772b54a08bae19f59d93ca456691e3ce3cbb00da
Parent:        e593213b875e96a3de77594f7ce8dd1809a930a0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 24 10:06:58 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 29 14:27:32 2015 -0500

vgcreate: improve checks for existing global lock

This tries harder to avoid creating duplicate global locks in
sanlock VGs by refusing to create a new sanlock VG with a
global lock if other sanlock VGs exist that may have a gl.
---
 daemons/lvmlockd/lvmlockd-core.c |    6 -----
 lib/cache/lvmcache.c             |   13 +++++++++++
 lib/cache/lvmcache.h             |    2 +
 lib/locking/lvmlockd.c           |   45 +++++++++++++++++++++++++++++--------
 4 files changed, 50 insertions(+), 16 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 7375d9e..1361569 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3341,12 +3341,6 @@ static void client_send_result(struct client *cl, struct action *act)
 		 * or if lockspaces exist, but not one with the global lock.
 		 * Given this detail, it may be able to procede without
 		 * the lock.
-		 *
-		 * FIXME: it would also help the caller to know if there
-		 * are other sanlock VGs that have not been started.
-		 * If there are, then one of them might have a global
-		 * lock enabled.  In that case, vgcreate may not want
-		 * to create a new sanlock vg with gl enabled.
 		 */
 		pthread_mutex_lock(&lockspaces_mutex);
 		if (list_empty(&lockspaces))
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 36926f2..cfa1d5f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2345,3 +2345,16 @@ int lvmcache_lookup_mda(struct lvmcache_vgsummary *vgsummary)
 
 	return 0;
 }
+
+int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	dm_list_iterate_items(vginfo, &_vginfos) {
+		if (vginfo->lock_type && !strcmp(vginfo->lock_type, "sanlock"))
+			return 1;
+	}
+
+	return 0;
+}
+
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 008b194..76b9b10 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -188,4 +188,6 @@ int lvmcache_found_duplicate_pvs(void);
 
 void lvmcache_set_preferred_duplicates(const char *vgid);
 
+int lvmcache_contains_lock_type_sanlock(struct cmd_context *cmd);
+
 #endif
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index e9d7882..84eb861 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1177,23 +1177,48 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 		 * skip acquiring the global lock when creating this initial
 		 * VG, and enable the global lock in this VG.
 		 *
-		 * Here we assume that this is an initial bootstrap condition
-		 * based on the fact that lvmlockd has seen no lockd VGs.
-		 * (A commmand line option could be added to allow the user
-		 * to make this initial bootstrap condition explicit.)
+		 * This initial bootstrap condition is identified based on
+		 * two things:
 		 *
-		 * That assumption might be wrong.  It is possible that a global
-		 * lock does exist in a VG that has not yet been seen.  If that
-		 * VG appears after this creates a new VG with a new enabled
-		 * global lock, then there will be two VGs containing enabled
-		 * global locks, and one will need to be disabled by the user.
+		 * 1. No sanlock VGs have been started in lvmlockd, causing
+		 *    lvmlockd to return NO_GL_LS/NO_LOCKSPACES.
+		 *
+		 * 2. No sanlock VGs are seen in lvmcache after the disk
+		 *    scan performed in lvmetad_validate_global_cache().
+		 *
+		 * If both of those are true, we go ahead and create this new
+		 * VG which will have the global lock enabled.  However, this
+		 * has a shortcoming: another sanlock VG may exist that hasn't
+		 * appeared to the system yet.  If that VG has its global lock
+		 * enabled, then when it appears later, duplicate global locks
+		 * will be seen, and a warning will indicate that one of them
+		 * should be disabled.
+		 *
+		 * The two bootstrap conditions have another shortcoming to the
+		 * opposite effect:  other sanlock VGs may be visible to the
+		 * system, but none of them have a global lock enabled.
+		 * In that case, it would make sense to create this new VG with
+		 * an enabled global lock.  (FIXME: we could detect that none
+		 * of the existing sanlock VGs have a gl enabled and allow this
+		 * vgcreate to go ahead.)  Enabling the global lock in one of
+		 * the existing sanlock VGs is currently the simplest solution.
 		 */
 
 		if ((lockd_flags & LD_RF_NO_GL_LS) &&
 		    (lockd_flags & LD_RF_NO_LOCKSPACES) &&
 		    !strcmp(vg_lock_type, "sanlock")) {
-			log_print_unless_silent("Enabling sanlock global lock");
 			lvmetad_validate_global_cache(cmd, 1);
+			/*
+			 * lvmcache holds provisional VG lock_type info because
+			 * lvmetad_validate_global_cache did a disk scan.
+			 */
+			if (lvmcache_contains_lock_type_sanlock(cmd)) {
+				/* FIXME: we could check that all are started, and then check that none have gl enabled. */
+				log_error("Global lock failed: start existing sanlock VGs to access global lock.");
+				log_error("(If all sanlock VGs are started, enable global lock with lvmlockctl.)");
+				return 0;
+			}
+			log_print_unless_silent("Enabling sanlock global lock");
 			return 1;
 		}
 


