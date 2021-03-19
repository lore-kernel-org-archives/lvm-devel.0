From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 19 Mar 2021 23:17:12 +0000 (GMT)
Subject: main - gcc: ensure buffer ends with 0
Message-ID: <20210319231712.47681385783D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d37b19aaaab0c28f4d1e4ae0690c73c0031a027b
Commit:        d37b19aaaab0c28f4d1e4ae0690c73c0031a027b
Parent:        79d8d06217b6e0ac2ef8d0303ce84f748faebb9b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 23:08:08 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 19 23:21:18 2021 +0100

gcc: ensure buffer ends with 0

---
 lib/commands/toolcontext.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 92008a641..75634caff 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -230,7 +230,7 @@ static void _get_sysfs_dir(struct cmd_context *cmd, char *buf, size_t buf_size)
 		return;
 	}
 
-	strncpy(buf, sys_mnt, buf_size);
+	(void) dm_strncpy(buf, sys_mnt, buf_size);
 }
 
 static uint32_t _parse_debug_fields(struct cmd_context *cmd, int cfg, const char *cfgname)


