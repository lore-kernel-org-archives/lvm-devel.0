From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:38 +0000 (UTC)
Subject: master - clvmd: move call of cluster_closedown
Message-ID: <20140321213138.19FDE60F20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c45cd6eb8d0272b6700d0b0c6f2baa82fe67f37d
Commit:        c45cd6eb8d0272b6700d0b0c6f2baa82fe67f37d
Parent:        fc39ad677b3f4ffe8d4bba975e1628fb8f141921
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 21:19:54 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:23 2014 +0100

clvmd: move call of cluster_closedown

We have to close cluster in some predicatable way,
otherwise we may access released memory from different
threads.

So move closedown till the point we know all thread
are closed. New messages from cluster are discarded.
---
 daemons/clvmd/clvmd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 4f6a6df..3890347 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -636,6 +636,8 @@ int main(int argc, char *argv[])
 		dm_free(delfd);
 	}
 
+	clops->cluster_closedown();
+
 	ret = 0;
 out:
 	dm_hash_destroy(lvm_params.excl_uuid);
@@ -957,7 +959,6 @@ static void main_loop(int local_sock, int cmd_timeout)
 	}
 
       closedown:
-	clops->cluster_closedown();
 	if (quit)
 		DEBUGLOG("SIGTERM received\n");
 }


