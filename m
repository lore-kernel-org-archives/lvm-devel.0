From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:43 +0000 (UTC)
Subject: master - dmeventd: using warning level
Message-ID: <20151022213343.8C3D760B67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=590091a4faa4a4eb66598137576e01e692fb9f8d
Commit:        590091a4faa4a4eb66598137576e01e692fb9f8d
Parent:        9488cbdd0bd3a410ec1e77454c6a18bdfe8612f5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 11:14:12 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:33:19 2015 +0200

dmeventd: using warning level

When dmevend notices problems, but continues to operate normally
change log level to warning.
---
 daemons/dmeventd/dmeventd.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index f2c417c..93df32e 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -2155,7 +2155,7 @@ int main(int argc, char *argv[])
 #ifdef __linux__
 	/* Systemd has adjusted oom killer for us already */
 	if (!_systemd_activation && !_protect_against_oom_killer())
-		log_error("Failed to protect against OOM killer.");
+		log_warn("WARNING: Failed to protect against OOM killer.");
 #endif
 
 	_init_thread_signals();
@@ -2187,8 +2187,8 @@ int main(int argc, char *argv[])
 			_unlock_mutex();
 			if (nothreads)
 				break;
-			log_error("There are still devices being monitored.");
-			log_error("Refusing to exit.");
+			log_warn("WARNING: There are still devices being monitored.");
+			log_warn("WARNING: Refusing to exit.");
 		}
 		_process_request(&fifos);
 		_cleanup_unused_threads();


