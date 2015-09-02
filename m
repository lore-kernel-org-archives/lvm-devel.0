From: okozina <okozina@fedoraproject.org>
Date: Wed,  2 Sep 2015 15:27:40 +0000 (UTC)
Subject: master - lvmpolld.8.in: add missing space
Message-ID: <20150902152740.4CE9061045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab5df4bc5c568bc8c49fadfc0d1998ff1a4dbcb1
Commit:        ab5df4bc5c568bc8c49fadfc0d1998ff1a4dbcb1
Parent:        7bbc128c3dd6e75524a4447c29ed7be2ace8e3b3
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Sep 2 16:52:03 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Sep 2 17:24:34 2015 +0200

lvmpolld.8.in: add missing space

---
 man/lvmpolld.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmpolld.8.in b/man/lvmpolld.8.in
index 5906f42..00ee1ab 100644
--- a/man/lvmpolld.8.in
+++ b/man/lvmpolld.8.in
@@ -52,7 +52,7 @@ Additionally, when \-f is given they are also sent to standard error.
 There are two classes of messages: wire and debug. Selecting 'all' supplies both
 and is equivalent to a comma-separated list \-l wire,debug.
 .TP
-.BR \-p ", " \-\-pidfile \fIpidfile_path
+.BR \-p ", " \-\-pidfile " " \fIpidfile_path
 Path to the pidfile. This overrides both the built-in default
 (#DEFAULT_PID_DIR#/lvmpolld.pid) and the environment variable
 \fBLVM_LVMPOLLD_PIDFILE\fP.  This file is used to prevent more


