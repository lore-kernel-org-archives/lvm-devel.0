From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 12 Aug 2016 19:37:22 +0000 (UTC)
Subject: master - notify: Fix hang with lvm shell & --enable-notify-dbus
Message-ID: <20160812193722.7F0BF60F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0973d6e3314cc0f0ff1e5024feb131c2187d97f2
Commit:        0973d6e3314cc0f0ff1e5024feb131c2187d97f2
Parent:        a185a2bea27db7cbd8b19df1bb85307fc5c246eb
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Aug 12 14:31:06 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Aug 12 14:36:43 2016 -0500

notify: Fix hang with lvm shell & --enable-notify-dbus

When lvm is compiled with --enable-notify-dbus and a user uses lvm
shell, after they issue 200+ commands the lvm shell will hang for
~30 seconds trying to notify the lvm dbus service that a change
has occurred.  This appears to be caused by resource exhaustion,
because the sockets used for dbus communication are not be closed.
---
 lib/notify/lvmnotify.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/notify/lvmnotify.c b/lib/notify/lvmnotify.c
index afad93b..e9f8e29 100644
--- a/lib/notify/lvmnotify.c
+++ b/lib/notify/lvmnotify.c
@@ -73,7 +73,7 @@ void lvmnotify_send(struct cmd_context *cmd)
 out:
 	sd_bus_error_free(&error);
 	sd_bus_message_unref(m);
-	sd_bus_unref(bus);
+	sd_bus_flush_close_unref(bus);
 }
 
 void set_vg_notify(struct cmd_context *cmd)


