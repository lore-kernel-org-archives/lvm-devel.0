From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:12 +0000 (UTC)
Subject: dev-mornfall-activate - mm: fix leak in fail path
Message-ID: <20130604192612.8D96E61084@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55fe07ad98315d9471a86affd0680749e349a0a6
Commit:        55fe07ad98315d9471a86affd0680749e349a0a6
Parent:        e926f22457774596d6051aa9e8ee22b884f2299d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 13 12:59:38 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 13 13:13:20 2013 +0200

mm: fix leak in fail path

If the dm_realloc would fail, the already allocate _maps_buffer
memory would have been lost (overwritten with NULL).
Fix this by using temporary line buffer.

Also add a minor cleanup to set end of buffer to '\0',
only when we really know the file size fits the preallocated buffer.
---
 WHATS_NEW        |    1 +
 lib/mm/memlock.c |   19 +++++++++++--------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2cdd0cd..11d3e6f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix memory resource leak in memlocking error path.
   Fix premature DM version checking which caused useless mapper/control access.
   Add "active" LV reporting field to show activation state.
   Add "monitor" segment reporting field to show dmevent monitoring status.
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 098de9e..08876b0 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -270,23 +270,26 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 		if (!_maps_buffer || len >= _maps_len) {
 			if (_maps_buffer)
 				_maps_len *= 2;
-			if (!(_maps_buffer = dm_realloc(_maps_buffer, _maps_len))) {
-				log_error("Allocation of maps buffer failed");
+			if (!(line = dm_realloc(_maps_buffer, _maps_len))) {
+				log_error("Allocation of maps buffer failed.");
 				return 0;
 			}
+			_maps_buffer = line;
 		}
 		if (lseek(_maps_fd, 0, SEEK_SET))
 			log_sys_error("lseek", _procselfmaps);
 		for (len = 0 ; len < _maps_len; len += n) {
-			if (!(n = read(_maps_fd, _maps_buffer + len, _maps_len - len))) {
-				_maps_buffer[len] = '\0';
+			if (!(n = read(_maps_fd, _maps_buffer + len, _maps_len - len)))
 				break; /* EOF */
+			if (n == -1) {
+				log_sys_error("read", _procselfmaps);
+				return 0;
 			}
-			if (n == -1)
-				return_0;
 		}
-		if (len < _maps_len)  /* fits in buffer */
+		if (len < _maps_len) { /* fits in buffer */
+			_maps_buffer[len] = '\0';
 			break;
+		}
 	}
 
 	line = _maps_buffer;
@@ -315,7 +318,7 @@ static void _lock_mem(struct cmd_context *cmd)
 	 * so even future adition of thread which may not even use lvm lib
 	 * will not block memory locked thread
 	 * Note: assuming _memlock_count_daemon is updated before _memlock_count
-         */
+	 */
 	_use_mlockall = _memlock_count_daemon ? 1 :
 		find_config_tree_bool(cmd, activation_use_mlockall_CFG);
 


