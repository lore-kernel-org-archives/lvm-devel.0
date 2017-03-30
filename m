From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 14:49:10 -0400
Subject: master - man: pregen file change
Message-ID: <201703301849.v2UInADG030909@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ed087aae504e419ff9712ce8479b04beec38e03
Commit:        0ed087aae504e419ff9712ce8479b04beec38e03
Parent:        92ac1da16af40d5ec81a00c24b07199447fd0989
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 20:48:53 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 20:48:53 2017 +0200

man: pregen file change

---
 man/lvmconfig.8_pregen |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index ec076b2..e6d34aa 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -10,7 +10,7 @@ lvmconfig - Display and manipulate configuration information
     [ \fIposition_args\fP ]
 .br
 .SH DESCRIPTION
-lvmconfig, lvm dumpconfig, lvm config produce
+lvmconfig, lvm config, lvm dumpconfig (for compatibility reasons, to be phased out) produce
 formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
 line settings from --config.


