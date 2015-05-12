From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 May 2015 15:22:14 +0000 (UTC)
Subject: master - lvmpolld.8.in: clarify the timeout parameter
Message-ID: <20150512152214.5D9606024B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e213aa17bd9ef648f8fc44047ab4bd8c8ff80959
Commit:        e213aa17bd9ef648f8fc44047ab4bd8c8ff80959
Parent:        cdb7ce6f17e01821268c38ec10fed65f0400cc55
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 12 10:20:39 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 12 17:16:31 2015 +0200

lvmpolld.8.in: clarify the timeout parameter

Remove references to systemd native service. Now
the libdaemon supports shutdown on idle no matter
the init process implementation installed.
---
 man/lvmpolld.8.in |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/man/lvmpolld.8.in b/man/lvmpolld.8.in
index 8573395..26e7afe 100644
--- a/man/lvmpolld.8.in
+++ b/man/lvmpolld.8.in
@@ -61,11 +61,8 @@ Path to the socket file. This overrides both the built-in default
 \fBLVM_LVMPOLLD_SOCKET\fP.
 .TP
 .B \-t \fItimeout_value
-When runs as native systemd service daemon may shutdown after being
-idle for the given time (in seconds). When the option is omitted or
-the value given is zero the daemon never shutdowns on idle. When
-the daemon doesn't run as native systemd service the timeout is
-ignored and never shutdowns on idle.
+The daemon may shutdown after being idle for the given time (in seconds). When the
+option is omitted or the value given is zero the daemon never shutdowns on idle.
 .TP
 .B \-B \fIlvm_binary_path
 Optional path to alternative LVM binary (default: #LVM_PATH#). Use for


