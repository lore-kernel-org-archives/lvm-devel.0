From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Sep 2021 13:26:31 +0000 (GMT)
Subject: main - debug: change message level
Message-ID: <20210915132631.06C833858418@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=944e560e960964217c7525a18c60bf17ca046e0c
Commit:        944e560e960964217c7525a18c60bf17ca046e0c
Parent:        ed59b50512f966125b972f9d2eafee3058f8063f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 15 14:04:04 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 15 15:24:56 2021 +0200

debug: change message level

These message do not cause command error - switch to debug.
---
 lib/mm/memlock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 1e6cedc5f..3d1a3927c 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -357,7 +357,7 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 			_maps_buffer = line;
 		}
 		if (lseek(_maps_fd, 0, SEEK_SET))
-			log_sys_error("lseek", _procselfmaps);
+			log_sys_debug("lseek", _procselfmaps);
 		for (len = 0 ; len < _maps_len; len += n) {
 			if (!(n = read(_maps_fd, _maps_buffer + len, _maps_len - len)))
 				break; /* EOF */
@@ -561,7 +561,7 @@ static void _unlock_mem(struct cmd_context *cmd)
 	if (!_use_mlockall) {
 		_restore_mmap();
 		if (close(_maps_fd))
-			log_sys_error("close", _procselfmaps);
+			log_sys_debug("close", _procselfmaps);
 		free(_maps_buffer);
 		_maps_buffer = NULL;
 		if (_mstats < unlock_mstats) {


