From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Aug 2017 08:24:04 -0400
Subject: master - lvmlockd: avoid double unlock of client_mutex
Message-ID: <201708251224.v7PCO42K005036@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=288e10cf8b990cd740fba409d6f20525209f4f43
Commit:        288e10cf8b990cd740fba409d6f20525209f4f43
Parent:        b3b1e788e16c77f6784f30b8e984f68792f8fa1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 25 14:07:45 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 25 14:20:59 2017 +0200

lvmlockd: avoid double unlock of client_mutex

Avoid double unlocking of client_mutex and
and unlock client_mutex in 'else' branch
since it's already unlocked in 'if (cl->dead)' branch.
---
 WHATS_NEW                        |    1 +
 daemons/lvmlockd/lvmlockd-core.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ac69c16..32bbc41 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Avoid double unlocking of client & lockspace mutexes in lvmlockd.
   Fix leaking of file descriptor for non-blocking filebased locking.
   Fix check for 2nd mda at end of disk fits if using pvcreate --restorefile.
   Use maximum metadataarea size that fits with pvcreate --restorefile.
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 36d84e2..253d86b 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4761,8 +4761,8 @@ static void *client_thread_main(void *arg_in)
 			} else {
 				pthread_mutex_unlock(&cl->mutex);
 			}
-		}
-		pthread_mutex_unlock(&client_mutex);
+		} else
+			pthread_mutex_unlock(&client_mutex);
 	}
 out:
 	return NULL;


