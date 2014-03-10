From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:26:56 +0000 (UTC)
Subject: master - clvmd: fix memleak on exit
Message-ID: <20140310112656.659B160CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=460c19df621d35260caceec7f598da1566263cd4
Commit:        460c19df621d35260caceec7f598da1566263cd4
Parent:        38ce06e448d54b21c214c174b08b45a18de2ac88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 8 23:16:31 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:21:32 2014 +0100

clvmd: fix memleak on exit

This patch will releases allocated private resources from
startup. Needs previous dm_zalloc patch to ensure unset
private pointer is NULL.

TODO: check on real cluster.
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 379117c..7d6f4d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Cleanup all client resources on clvmd exit.
   Use dm_zalloc to clear members of clvmd client struct.
   Use BLKID_CFLAGS when compiling with blkid support.
   Use correct rl_completion_func_t typedef for new readline.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 3d9bce7..e8375a8 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -633,6 +633,7 @@ int main(int argc, char *argv[])
 		 * break of 'clvmd' may access already free memory here.
 		 */
 		safe_close(&(delfd->fd));
+		cmd_client_cleanup(delfd);
 		dm_free(delfd);
 	}
 


