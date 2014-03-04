From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Mar 2014 15:41:52 +0000 (UTC)
Subject: master - tests: hide error message
Message-ID: <20140304154152.A67E56090F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a99cb8c7947e19291794aa80d5bcdc73fa6245f
Commit:        9a99cb8c7947e19291794aa80d5bcdc73fa6245f
Parent:        a01e2ff81c9e7f629d9011b7d69d9f2780a98484
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 4 16:41:07 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 4 16:41:07 2014 +0100

tests: hide error message

Make the logging looks normal for this case
---
 test/lib/harness.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/harness.c b/test/lib/harness.c
index d02e9de..4e9c54f 100644
--- a/test/lib/harness.c
+++ b/test/lib/harness.c
@@ -441,7 +441,7 @@ static void run(int i, char *f) {
 				perror("open /dev/kmsg");
 		} else if (read(fd_kmsg, NULL, 0) == -1) {
 			/* There is /dev/kmsg, but unreadable -> ignore it (RHEL6?) */
-			perror("read /dev/kmsg");
+			/* Expected error, stay quiet so log looks nice, perror("read /dev/kmsg"); */
 			close(fd_kmsg);
 			fd_kmsg = -1;
 		} else if (lseek(fd_kmsg, 0L, SEEK_END) == (off_t) -1)


