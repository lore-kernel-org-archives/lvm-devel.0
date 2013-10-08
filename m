From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  8 Oct 2013 21:49:29 +0000 (UTC)
Subject: master - libdaemon: Fix an invalid memory read.
Message-ID: <20131008214929.47A056146A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=808a5d945e3af27c7e79093f38d2dbe8370fee39
Commit:        808a5d945e3af27c7e79093f38d2dbe8370fee39
Parent:        d888a0557efc173336582ca94055e0630d5ceca8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 8 23:19:11 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 8 23:21:09 2013 +0200

libdaemon: Fix an invalid memory read.

---
 libdaemon/client/daemon-io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 906f375..e2c5180 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -38,7 +38,7 @@ int buffer_read(int fd, struct buffer *buffer) {
 		result = read(fd, buffer->mem + buffer->used, buffer->allocated - buffer->used);
 		if (result > 0) {
 			buffer->used += result;
-			if (!strncmp((buffer->mem) + buffer->used - 4, "\n##\n", 4)) {
+			if (buffer->used >= 4 && !strncmp((buffer->mem) + buffer->used - 4, "\n##\n", 4)) {
 				buffer->used -= 4;
 				buffer->mem[buffer->used] = 0;
 				break; /* success, we have the full message now */


