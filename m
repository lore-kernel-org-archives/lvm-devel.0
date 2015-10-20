From: okozina <okozina@fedoraproject.org>
Date: Tue, 20 Oct 2015 13:46:09 +0000 (UTC)
Subject: master - lvmetad.8.in: update man page with timeout info
Message-ID: <20151020134609.37825602B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c15649b3af94e4af573ada0f30e35f7d1fee5321
Commit:        c15649b3af94e4af573ada0f30e35f7d1fee5321
Parent:        f67a52677bdc95209c7adfa4575c833bed1659f1
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 20 13:33:29 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 20 15:45:21 2015 +0200

lvmetad.8.in: update man page with timeout info

---
 man/lvmetad.8.in |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index cdaf198..2acfd8b 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -10,6 +10,8 @@ lvmetad \(em LVM metadata cache daemon
 .IR pidfile_path ]
 .RB [ \-s
 .IR socket_path ]
+.RB [ \-t
+.IR timeout_value ]
 .RB [ \-f ]
 .RB [ \-h ]
 .RB [ \-V ]
@@ -97,6 +99,10 @@ Path to the socket file. This overrides both the built-in default
 \fBLVM_LVMETAD_SOCKET\fP.  To communicate successfully with lvmetad,
 all LVM2 processes should use the same socket path.
 .TP
+.B \-t \fItimeout_value
+The daemon may shutdown after being idle for the given time (in seconds). When the
+option is omitted or the value given is zero the daemon never shutdowns on idle.
+.TP
 .B \-V
 Display the version of lvmetad daemon.
 .SH ENVIRONMENT VARIABLES


