From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:16 +0100
Subject: [PATCH 12/29] Add test for 'read' result
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <725e7919102c477b04e9589a0c2b0f8004f68a74.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Static analyzer complains when read result is ignored.

So let's add some small check even when there is very low probablity to
fail in this place.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvmcmdline.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 192531d..f599613 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1191,15 +1191,17 @@ static const char *_get_cmdline(pid_t pid)
 {
 	static char _proc_cmdline[32];
 	char buf[256];
-	int fd;
+	int fd, n = 0;
 
 	snprintf(buf, sizeof(buf), DEFAULT_PROC_DIR "/%u/cmdline", pid);
 	if ((fd = open(buf, O_RDONLY)) > 0) {
-		read(fd, _proc_cmdline, sizeof(_proc_cmdline) - 1);
-		_proc_cmdline[sizeof(_proc_cmdline) - 1] = '\0';
+		if ((n = read(fd, _proc_cmdline, sizeof(_proc_cmdline) - 1)) < 0) {
+			log_sys_error("read", buf);
+			n = 0;
+		}
 		close(fd);
-	} else
-		_proc_cmdline[0] = '\0';
+	}
+	_proc_cmdline[n] = '\0';
 
 	return _proc_cmdline;
 }
-- 
1.7.3.2


