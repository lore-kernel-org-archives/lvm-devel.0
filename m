From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:48 +0000 (UTC)
Subject: master - singlenode: reset pointer when hash is destroyed
Message-ID: <20140321213148.7F1B960F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46ae028cd34597cfd54048edd99cb0f27ac542eb
Commit:        46ae028cd34597cfd54048edd99cb0f27ac542eb
Parent:        7041c8bf51844c314fd4ed3b5f20779959524320
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 23:34:11 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:25 2014 +0100

singlenode: reset pointer when hash is destroyed

Just keep pointer consistent.
---
 daemons/clvmd/clvmd-singlenode.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index cad9acb..a3a1960 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -109,6 +109,7 @@ static int _init_cluster(void)
 	r = init_comms();
 	if (r) {
 		dm_hash_destroy(_locks);
+		_locks = NULL;
 		return r;
 	}
 


