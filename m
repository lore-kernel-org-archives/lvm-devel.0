From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 27 Sep 2010 17:31:55 +0200
Subject: [PATCH 1/1] Maps fix
In-Reply-To: <cover.1285601408.git.zkabelac@redhat.com>
References: <cover.1285601408.git.zkabelac@redhat.com>
Message-ID: <867a4bada2ee53fcf310d54788e3b08868d5031e.1285601408.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Read complete content of /proc/self/maps into one buffer without
realocation in the middle of reading and before doing any m/unlock
operation with these lines - as some of them gets change.
With previous implementation we've read some mappings twice ([stack])

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mm/memlock.c |   53 ++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 73d2407..15892e7 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -76,7 +76,9 @@ static const char * const _blacklist_maps[] = {
 typedef enum { LVM_MLOCK, LVM_MUNLOCK } lvmlock_t;
 
 static unsigned _use_mlockall;
-static FILE *_mapsh;
+static int _maps_fd;
+static size_t _maps_len = 8192; /* Initial buffer size for reading /proc/self/maps */
+static char *_maps_buffer;
 static char _procselfmaps[PATH_MAX] = "";
 #define SELF_MAPS "/self/maps"
 
@@ -193,7 +195,7 @@ static int _maps_line(struct cmd_context *cmd, lvmlock_t lock,
 
 static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats)
 {
-	char *line = NULL;
+	char *line, *line_end;
 	size_t len;
 	ssize_t n;
 	int ret = 1;
@@ -222,15 +224,39 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 		(void)strerror(0);
 	/* Reset statistic counters */
 	*mstats = 0;
-	rewind(_mapsh);
 
-	while ((n = getline(&line, &len, _mapsh)) != -1) {
-		line[n > 0 ? n - 1 : 0] = '\0'; /* remove \n */
-		if (!_maps_line(cmd, lock, line, mstats))
-                        ret = 0;
+	/* read mapping into a single memory chunk without reallocation
+	 * in the middle of reading maps file */
+	for (len = 0;;) {
+		if (!_maps_buffer || len >= _maps_len) {
+			if (_maps_buffer)
+				_maps_len *= 2;
+			if (!(_maps_buffer = dm_realloc(_maps_buffer, _maps_len))) {
+				log_error("Allocation of maps buffer failed");
+				return 0;
+			}
+		}
+		lseek(_maps_fd, 0, SEEK_SET);
+		for (len = 0 ; len < _maps_len; len += n) {
+			if (!(n = read(_maps_fd, _maps_buffer + len, _maps_len - len))) {
+				_maps_buffer[len] = '0';
+				break; /* EOF */
+			}
+			if (n == -1)
+				return_0;
+		}
+		if (len < _maps_len)  /* fits in buffer */
+			break;
 	}
 
-	free(line);
+	line = _maps_buffer;
+
+	while ((line_end = strchr(line, '\n'))) {
+		*line_end = '\0'; /* remove \n */
+		if (!_maps_line(cmd, lock, line, mstats))
+			ret = 0;
+		line = line_end + 1;
+	}
 
 	log_debug("%socked %ld bytes",
 		  (lock == LVM_MLOCK) ? "L" : "Unl", (long)*mstats);
@@ -260,8 +286,8 @@ static void _lock_mem(struct cmd_context *cmd)
 			return;
 		}
 
-		if (!(_mapsh = fopen(_procselfmaps, "r"))) {
-			log_sys_error("fopen", _procselfmaps);
+		if (!(_maps_fd = open(_procselfmaps, O_RDONLY))) {
+			log_sys_error("open", _procselfmaps);
 			return;
 		}
 	}
@@ -289,9 +315,10 @@ static void _unlock_mem(struct cmd_context *cmd)
 		stack;
 
 	if (!_use_mlockall) {
-		if (fclose(_mapsh))
-			log_sys_error("fclose", _procselfmaps);
-
+		if (close(_maps_fd))
+			log_sys_error("close", _procselfmaps);
+		dm_free(_maps_buffer);
+		_maps_buffer = NULL;
 		if (_mstats < unlock_mstats)
 			log_error(INTERNAL_ERROR "Maps lock %ld < unlock %ld",
 				  (long)_mstats, (long)unlock_mstats);
-- 
1.7.3


