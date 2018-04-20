From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:46 -0400
Subject: master - cleanup: avoid compiler warn
Message-ID: <201804201102.w3KB2k15031395@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=037c234eaaabd4989e769e1f9db47c8452fa4966
Commit:        037c234eaaabd4989e769e1f9db47c8452fa4966
Parent:        73cda0437f8added751716c9bbae33fe321b4963
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 29 18:49:42 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

cleanup: avoid compiler warn

When variable is unused...
---
 daemons/cmirrord/cluster.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 5b8b68d..e56d8f3 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -166,7 +166,9 @@ int cluster_send(struct clog_request *rq)
 {
 	int r;
 	int found = 0;
+#if CMIRROR_HAS_CHECKPOINT
 	int count = 0;
+#endif
 	struct iovec iov;
 	struct clog_cpg *entry;
 


