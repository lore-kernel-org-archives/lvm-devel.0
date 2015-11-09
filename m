From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:29:10 +0000 (UTC)
Subject: master - cleanup: coverity quiet
Message-ID: <20151109092910.87C8761147@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1dab26be0ee7eec11a6e91ab715808ddf016355
Commit:        b1dab26be0ee7eec11a6e91ab715808ddf016355
Parent:        11151121aa25c331cdb821281b0c4719bed040ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 8 17:01:59 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:52 2015 +0100

cleanup: coverity quiet

While through all codepaths we never 'read' lock_id unless LCKF_CONVERT,
coverity cannot decrypt this.

As since it's usually better to pass in 'well-defined' data structures
preset lock_id to 0.
---
 daemons/clvmd/lvm-functions.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 99e7317..ae9d22b 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -291,6 +291,7 @@ static int hold_lock(char *resource, int mode, int flags)
 		}
 
 		lvi->lock_mode = mode;
+		lvi->lock_id = 0;
 		status = sync_lock(resource, mode, flags & ~LCKF_CONVERT, &lvi->lock_id);
 		saved_errno = errno;
 		if (status) {


