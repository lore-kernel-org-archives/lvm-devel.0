From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Dec 2022 15:23:35 +0000 (GMT)
Subject: main - cov: fix buffer size usage
Message-ID: <20221220152335.623323858000@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f443d16fd7409b46b77be2aa74090ab558c51425
Commit:        f443d16fd7409b46b77be2aa74090ab558c51425
Parent:        44a2f2df9281ac0f5aef67d5f3c32fc2ee6ad0e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 20 13:58:31 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 20 15:04:36 2022 +0100

cov: fix buffer size usage

Count with extra 1 byte for buffer end '\0'.
---
 libdm/dm-tools/dmfilemapd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libdm/dm-tools/dmfilemapd.c b/libdm/dm-tools/dmfilemapd.c
index d547e59d5..f6c04e03e 100644
--- a/libdm/dm-tools/dmfilemapd.c
+++ b/libdm/dm-tools/dmfilemapd.c
@@ -172,7 +172,7 @@ static int _is_open_in_pid(pid_t pid, const char *path)
 		if (pid_dp->d_name[0] == '.')
 			continue;
 		if ((len = readlinkat(dirfd(pid_d), pid_dp->d_name, link_buf,
-				      sizeof(link_buf))) < 0) {
+				      (sizeof(link_buf) - 1))) < 0) {
 			log_error("readlink failed for " DEFAULT_PROC_DIR
 				  "/%d/fd/.", pid);
 			goto bad;

