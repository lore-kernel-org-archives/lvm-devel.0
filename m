From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:56 -0500
Subject: master - dmeventd: unlock lvm2 lock on error path
Message-ID: <201812212046.wBLKkulI021423@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a13fa75d8e89d2eb88a707e35ba472b7d6189d07
Commit:        a13fa75d8e89d2eb88a707e35ba472b7d6189d07
Parent:        65cb8efd16f636a42f6ce13b29d86298f10667aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 21:29:05 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:43:36 2018 +0100

dmeventd: unlock lvm2 lock on error path

New code missed to unlock locked lvm2 on error path when
command is not configured.
---
 WHATS_NEW                                    |    1 +
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1a9c521..1bebff6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Fix missing unlock on lvm2 dmeventd plugin error path initialization.
   Improve Makefile dependency tracking.
   Move VDO support towards V2 target (6.2) support.
   Fix missing proper initialization of pv_list struct when adding pv.
diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 95ec360..04bc899 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -159,6 +159,7 @@ int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
 			dmeventd_lvm2_lock();
 			if (!dmeventd_lvm2_run(cmd) ||
 			    !(env = getenv(cmd))) {
+				dmeventd_lvm2_unlock();
 				log_error("Unable to find configured command.");
 				return 0;
 			}


