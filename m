From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:27 +0000 (UTC)
Subject: master - dmeventd: correct ret code for fail
Message-ID: <20151013140327.328D260E41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e1c08bb6a90acdbf56e362ee017bd48de13a535
Commit:        7e1c08bb6a90acdbf56e362ee017bd48de13a535
Parent:        c7b4359ff41634096770d464d362d43d2e82bbda
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 09:49:59 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:38:49 2015 +0200

dmeventd: correct ret code for fail

As  _do_register_device() calls  register_device() function that returns
1 success & 0 fail -  ret = -ENOMEM for fail case instead of 0.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e760875..a1c121a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Return -ENOMEM when device registration fails instead of 0 (=success).
   Enforce writethrough mode for cleaner policy.
   Add support for recognition and deactivation of MD devices to blkdeactivate.
   Move target status functions out of libdm-deptree.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 1ff5bf9..ffc941f 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1070,8 +1070,10 @@ static int _register_for_event(struct message_data *message_data)
 	if (!(thread = _lookup_thread_status(message_data))) {
 		_unlock_mutex();
 
-		if (!(ret = _do_register_device(thread_new)))
-			goto out;
+		if (!_do_register_device(thread_new)) {
+			ret = -ENOMEM;
+			goto_out;
+		}
 
 		thread = thread_new;
 		thread_new = NULL;


