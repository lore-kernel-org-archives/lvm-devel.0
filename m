From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:09 +0000 (UTC)
Subject: master - do_flock: mark descriptor as closed
Message-ID: <20131122200909.42FCE61133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b4fc397de6a456efb8b8cce1e7d0048d4573f7cc
Commit:        b4fc397de6a456efb8b8cce1e7d0048d4573f7cc
Parent:        782a356e7cce8d0d32850677cdb5a9b28996471e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 13:16:12 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:55 2013 +0100

do_flock: mark descriptor as closed

Keep the structure content valid in error path
and mark descriptor as closed (-1).
---
 lib/locking/file_locking.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index ab3dabd..3fa0a2d 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -163,6 +163,7 @@ static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock
 			log_sys_error("flock", file);
 			if (close(*fd))
 				log_sys_error("close", file);
+			*fd = -1;
 			return 0;
 		}
 


