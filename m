From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 Oct 2015 08:55:15 +0000 (UTC)
Subject: master - cleanup: drop debug
Message-ID: <20151023085515.6B7FA6100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a7bea0f0f187a3d3332dda2cca2ecd0300b8031
Commit:        1a7bea0f0f187a3d3332dda2cca2ecd0300b8031
Parent:        b5b2a5483450dff10fd23a7b712649729e619b0d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 23 10:46:58 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 23 10:54:13 2015 +0200

cleanup: drop debug

---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index aaf9a49..cda19a3 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -100,7 +100,6 @@ void dmeventd_lvm2_exit(void)
 		lvm2_run(_lvm_handle, "_memlock_dec");
 		dm_pool_destroy(_mem_pool);
 		_mem_pool = NULL;
-		log_debug("lvm plugin exiting.");
 		lvm2_exit(_lvm_handle);
 		_lvm_handle = NULL;
 		log_debug("lvm plugin exited.");


