From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 20 Apr 2015 10:14:07 +0000 (UTC)
Subject: master - debug: use epoch for dmeventd logging
Message-ID: <20150420101407.D7E1060DA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bff3a1651d1b5b6b83a978f5896655b8df84ffc0
Commit:        bff3a1651d1b5b6b83a978f5896655b8df84ffc0
Parent:        5723a7cd7e857c4b5899b19060d17cac1b14e6b6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 20 10:04:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 20 12:12:22 2015 +0200

debug: use epoch for dmeventd logging

When LVM_LOG_FILE_EPOCH is set, route lvm command debug message
to lvm.conf log file instead of syslog.
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 80ed83a..9b08bbe 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -102,7 +102,8 @@ int dmeventd_lvm2_init(void)
 		goto out;
 
 	if (!_lvm_handle) {
-		lvm2_log_fn(_temporary_log_fn);
+		if (!getenv("LVM_LOG_FILE_EPOCH"))
+			lvm2_log_fn(_temporary_log_fn);
 		if (!(_lvm_handle = lvm2_init())) {
 			dm_pool_destroy(_mem_pool);
 			_mem_pool = NULL;


