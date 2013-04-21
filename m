From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:28 +0000 (UTC)
Subject: master - dmeventd: prevent double free
Message-ID: <20130421211628.9736F145A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8184a57c2b18d606fb533a87319768c90000e308
Commit:        8184a57c2b18d606fb533a87319768c90000e308
Parent:        5ea466673af377328a7ed50d6fb24e66a478b44b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 20:49:57 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:02:36 2013 +0200

dmeventd: prevent double free

Since device.name is relased on more places, mark already
released name with NULL.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6e45a4c..afaf266 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Prevent double free error after dmeventd call of _fill_device_data().
   Update dmevent structure message_data to simplify/fix error path handling.
   Validate passed params to dm_get_status_raid/thin/thin_pool(). 
   Fix 'dmsetup splitname -o' to not fail if used without '-c' switch (1.02.68).
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 35a2b25..c3d9671 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -411,6 +411,8 @@ static int _fill_device_data(struct thread_status *ts)
       fail:
 	dm_task_destroy(dmt);
 	dm_free(ts->device.name);
+	ts->device.name = NULL;
+
 	return 0;
 }
 


