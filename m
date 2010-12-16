From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:19 +0100
Subject: [PATCH 11/20] Add test for 'read' result
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <140b13aa499239c5cf78f51e0b45411b25533171.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Read result should not be ignored.
Add some small check even when there is very low probability to
fail in this place.

FIXME Generic read routine should be used.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvmcmdline.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9f20d4b..dcb1f28 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1191,15 +1191,19 @@ static const char *_get_cmdline(pid_t pid)
 {
 	static char _proc_cmdline[32];
 	char buf[256];
-	int fd;
+	int fd, n = 0;
 
 	snprintf(buf, sizeof(buf), DEFAULT_PROC_DIR "/%u/cmdline", pid);
+	/* FIXME Use generic read code. */
 	if ((fd = open(buf, O_RDONLY)) > 0) {
-		read(fd, _proc_cmdline, sizeof(_proc_cmdline) - 1);
-		_proc_cmdline[sizeof(_proc_cmdline) - 1] = '\0';
-		close(fd);
-	} else
-		_proc_cmdline[0] = '\0';
+		if ((n = read(fd, _proc_cmdline, sizeof(_proc_cmdline) - 1)) < 0) {
+			log_sys_error("read", buf);
+			n = 0;
+		}
+		if (close(fd))
+			log_sys_error("close", buf);
+	}
+	_proc_cmdline[n] = '\0';
 
 	return _proc_cmdline;
 }
-- 
1.7.3.3


