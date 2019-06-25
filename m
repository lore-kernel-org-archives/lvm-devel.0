From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:44:47 -0400
Subject: stable-2.02 - cov: unlock lvm2 mutex on error path
Message-ID: <201906251544.x5PFilCb012383@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b42cdad0c27d79766c7e9aae50d13cd93a2ffbf
Commit:        3b42cdad0c27d79766c7e9aae50d13cd93a2ffbf
Parent:        49813abc003180a38f9cd1e6c75f68311d005a50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 15:26:30 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:31:39 2019 +0200

cov: unlock lvm2 mutex on error path

Add missing unlock call on theretical error path where
we would be missing our configured command.
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 5be11f1..be58aac 100644
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


