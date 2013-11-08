From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri,  8 Nov 2013 15:56:58 +0000 (UTC)
Subject: master - mirror: Handle failures in tmp mirror used when up-converting.
Message-ID: <20131108155658.42F8F60F39@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7de533ad12972f5a9c5bf2d2b477d8320f7e4a8e
Commit:        7de533ad12972f5a9c5bf2d2b477d8320f7e4a8e
Parent:        b6b5299d1e1f6bdddb9bda30c4f37aaccbe3df44
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Nov 8 09:52:00 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Nov 8 09:52:00 2013 -0600

mirror: Handle failures in tmp mirror used when up-converting.

Failures in the temporary mirror used when up-converting cause dmeventd
to issue 'lvconvert --repair' on the sub-LV, <lv_name>_mimagetmp_?.  The
'lvconvert' command refuses to deal with this sub-LV outright - it
expects to be given the name of the top-level LV.  So, just like we do
with mirrored logs, we strip-off the portion of the name that is not
the top-level LV and issue the command on the top-level LV instead.
---
 WHATS_NEW                                    |    1 +
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f0a764b..5eb4abe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104 -
 ===================================
+  Handle failures in temporary mirror used when adding images to mirrors.
   Fix and improve logic for implicitely exclusive activations.
   Return success when LV cannot be activated because of volume_list filter.
   Return proper error state for remote exclusive activation.
diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 5d5a46b..6d2c3de 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -159,8 +159,8 @@ int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
 	}
 
 	/* strip off the mirror component designations */
-	layer = strstr(lv, "_mlog");
-	if (layer)
+	if ((layer = strstr(lv, "_mimagetmp")) ||
+	    (layer = strstr(lv, "_mlog")))
 		*layer = '\0';
 
 	r = dm_snprintf(buffer, size, "%s %s/%s", cmd, vg, lv);


