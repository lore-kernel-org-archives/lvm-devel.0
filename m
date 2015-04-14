From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 14 Apr 2015 07:50:36 +0000 (UTC)
Subject: master - man: lvmconf: more notes on --services option
Message-ID: <20150414075036.56DEA61383@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5651f44e3056c0e0e5f0c3d05c29c575782379e
Commit:        d5651f44e3056c0e0e5f0c3d05c29c575782379e
Parent:        96124c6c0b866bc4d135074a7947e1a0911dd86f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 14 09:49:56 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 14 09:49:56 2015 +0200

man: lvmconf: more notes on --services option

---
 man/lvmconf.8.in |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/man/lvmconf.8.in b/man/lvmconf.8.in
index de86a2d..1ce7061 100644
--- a/man/lvmconf.8.in
+++ b/man/lvmconf.8.in
@@ -20,7 +20,9 @@ lvmconf \(em LVM configuration modifier
 
 .SH "DESCRIPTION"
 lvmconf is a script that modifies the locking configuration in
-an lvm configuration file. See \fBlvm.conf\fP(5).
+an lvm configuration file. See \fBlvm.conf\fP(5). In addition
+to that, it can also set Systemd or SysV services according to
+changes in the lvm configuration if needed.
 
 .SH "OPTIONS"
 .TP
@@ -51,7 +53,8 @@ Set external \fBlocking_library\fR locking library to load if an external lockin
 .TP
 .BR \-\-services
 In addition to setting the lvm configuration, also enable or disable related Systemd or SysV
-clvmd and lvmetad services.
+clvmd and lvmetad services. This script does not configure services provided by cluster resource
+agents.
 .TP
 .BR \-\-mirrorservice
 Also enable or disable optional cmirrord service when handling services (applicable only with \-\-services).


