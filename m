From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:34:54 -0400
Subject: master - coverity: move declaration out of the loop
Message-ID: <201803172234.w2HMYsRd011228@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4c69320fcccaf5257039c3489d5227e82183f8a
Commit:        b4c69320fcccaf5257039c3489d5227e82183f8a
Parent:        f2d0eefa770468e8cdd126ce09a251bdf804884e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 13:57:40 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

coverity: move declaration out of the loop

Move declaration of count counter outside the while loop.
---
 daemons/cmirrord/cluster.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 94be563..5b8b68d 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -166,6 +166,7 @@ int cluster_send(struct clog_request *rq)
 {
 	int r;
 	int found = 0;
+	int count = 0;
 	struct iovec iov;
 	struct clog_cpg *entry;
 
@@ -203,8 +204,6 @@ int cluster_send(struct clog_request *rq)
 
 #if CMIRROR_HAS_CHECKPOINT
 	do {
-		int count = 0;
-
 		r = cpg_mcast_joined(entry->handle, CPG_TYPE_AGREED, &iov, 1);
 		if (r != SA_AIS_ERR_TRY_AGAIN)
 			break;


