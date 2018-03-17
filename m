From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:34:45 -0400
Subject: master - coverity: validate descriptor
Message-ID: <201803172234.w2HMYjYb011187@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=26c58027fb9df068c927abe61336ff6364fe3d0e
Commit:        26c58027fb9df068c927abe61336ff6364fe3d0e
Parent:        f331eb1c0d060529a3b5e6517c8ac423e21796d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 13:53:12 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

coverity: validate descriptor

Since this function is called with 'fd == -1', but Coverity can't see
this path can't be visited with this argument, add explicit check for
valid descriptor.
---
 daemons/clvmd/clvmd.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index e15a40a..829c5e5 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1999,6 +1999,9 @@ static int send_message(void *buf, int msglen, const char *csid, int fd,
 		return clops->cluster_send_message(buf, msglen, csid, errtext);
 	}
 
+	if (fd < 0)
+		return 0;
+
 	/* Make sure it all goes */
 	for (ptr = 0; ptr < msglen;) {
 		if ((len = write(fd, (char*)buf + ptr, msglen - ptr)) <= 0) {


