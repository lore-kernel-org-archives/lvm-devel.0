From: Mike Snitzer <snitzer@redhat.com>
Date: Sat, 9 Jan 2010 00:26:42 -0500
Subject: [PATCH] reset lvmcache's _vgs_locked in reset_locking()
Message-ID: <20100109052641.GA3444@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following log shows that the forked polldaemons are _not_ using
blocking VG locks (WB).  The patch that follows resolves this.

Jan  8 22:28:51 really-raw lvm[28447]: Logging initialised at Fri Jan  8 22:28:51 2010
Jan  8 22:28:51 really-raw lvm[28447]: Set umask to 0077
Jan  8 22:28:51 really-raw lvm[28447]: File-based locking selected.
Jan  8 22:28:51 really-raw lvm[28447]: Finding all volume groups
Jan  8 22:28:51 really-raw lvm[28447]: Finding volume group "test"
Jan  8 22:28:51 really-raw lvm[28447]: Locking /var/lock/lvm/V_test RB
Jan  8 22:28:51 really-raw lvm[28447]: Found volume group "test"
Jan  8 22:28:51 really-raw lvm[28447]: Found volume group "test"
Jan  8 22:28:53 really-raw lvm[28447]: Spawning background lvconvert process for testlv1
Jan  8 22:28:53 really-raw lvm[28447]: Checking progress every 15 seconds
Jan  8 22:28:53 really-raw lvm[28447]: Forking background process
Jan  8 22:28:53 really-raw lvm[28447]: Found volume group "test"
Jan  8 22:28:53 really-raw lvm[28447]: Spawning background lvconvert process for testlv2
Jan  8 22:28:53 really-raw lvm[28447]: Checking progress every 15 seconds
Jan  8 22:28:53 really-raw lvm[28447]: Forking background process
Jan  8 22:28:53 really-raw lvm[28447]: Activated 3 logical volumes in volume group test
Jan  8 22:28:53 really-raw lvm[28447]: 5 logical volume(s) in volume group "test" now active
Jan  8 22:28:53 really-raw lvm[28447]: Unlocking /var/lock/lvm/V_test
Jan  8 22:28:53 really-raw lvm[28447]: Wiping internal VG cache

Jan  8 22:29:08 really-raw lvm[28491]: Locking /var/lock/lvm/V_test W 
Jan  8 22:29:08 really-raw lvm[28491]: Wiping cache of LVM-capable devices

Jan  8 22:29:08 really-raw lvm[28524]: Locking /var/lock/lvm/V_test W 
Jan  8 22:29:08 really-raw lvm[28524]: /var/lock/lvm/V_test: flock failed: Resource temporarily unavailable
Jan  8 22:29:08 really-raw lvm[28524]: Can't get lock for test
Jan  8 22:29:08 really-raw lvm[28524]: ABORTING: Can't reread VG for test/testlv2
Jan  8 22:29:08 really-raw lvm[28524]: Activated 3 logical volumes in volume group test
Jan  8 22:29:08 really-raw lvm[28524]: 5 logical volume(s) in volume group "test" now active
Jan  8 22:29:08 really-raw lvm[28524]: Wiping internal VG cache

Jan  8 22:29:10 really-raw lvm[28491]: testlv1: Merged: 14.7%
Jan  8 22:29:10 really-raw lvm[28491]: Unlocking /var/lock/lvm/V_test
Jan  8 22:29:25 really-raw lvm[28491]: Locking /var/lock/lvm/V_test W 
Jan  8 22:29:25 really-raw lvm[28491]: testlv1: Merged: 10.6%
Jan  8 22:29:25 really-raw lvm[28491]: Unlocking /var/lock/lvm/V_test


lock_vol() will always use non-blocking VG locking unless
reset_locking() also resets the lvmcache's '_vgs_locked'

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 1cd6a2e..41e39eb 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -307,6 +307,11 @@ int vgs_locked(void)
 	return _vgs_locked;
 }
 
+void reset_vgs_locked(void)
+{
+	_vgs_locked = 0;
+}
+
 static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
 				struct lvmcache_info *info)
 {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index e2d749e..0807f5f 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -95,6 +95,7 @@ struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid);
 int vgs_locked(void);
+void reset_vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgnames */
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index e1881af..1a3d1b9 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -190,6 +190,8 @@ void reset_locking(void)
 
 	if (was_locked)
 		_unblock_signals();
+
+	reset_vgs_locked();
 }
 
 static void _update_vg_lock_count(const char *resource, uint32_t flags)


