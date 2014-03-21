From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:25 +0000 (UTC)
Subject: master - activate: report release with critical section
Message-ID: <20140321213125.83A0560FB4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ca16c694668ded9b33c22dc54316dd4bd77151b
Commit:        0ca16c694668ded9b33c22dc54316dd4bd77151b
Parent:        e5382c063d2549d3a28b3182218b7978e0c22442
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 10:31:21 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:22 2014 +0100

activate: report release with critical section

This function is typically called for cmd context refresh or destroy.
On the non-clustered case we already unlocked all messages,
however when i.e. 'clvmd' gets break signal it may have
still couple messages queued.

For now just report an error.
---
 lib/activate/activate.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 565634f..9d404e5 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2348,11 +2348,16 @@ int pv_uses_vg(struct physical_volume *pv,
 
 void activation_release(void)
 {
-	dev_manager_release();
+	if (critical_section())
+		/* May leak stacked operation */
+		log_error("Releasing activation in critical section.");
+
+	fs_unlock(); /* Implicit dev_manager_release(); */
 }
 
 void activation_exit(void)
 {
+	activation_release();
 	dev_manager_exit();
 }
 #endif


