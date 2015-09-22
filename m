From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Sep 2015 12:28:58 +0000 (UTC)
Subject: master - man: drop superfluous '--' in lvmconf man page for --enable/disable-halvm
Message-ID: <20150922122858.3982E60F42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd773dffb2ba2bf421441065f87562070e67dfd6
Commit:        fd773dffb2ba2bf421441065f87562070e67dfd6
Parent:        001f747963d66e4cff8e827afb710961193b9f03
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 22 14:27:40 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 22 14:28:31 2015 +0200

man: drop superfluous '--' in lvmconf man page for --enable/disable-halvm

---
 man/lvmconf.8.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvmconf.8.in b/man/lvmconf.8.in
index 1ce7061..44cb52b 100644
--- a/man/lvmconf.8.in
+++ b/man/lvmconf.8.in
@@ -6,8 +6,8 @@ lvmconf \(em LVM configuration modifier
 .B lvmconf
 .RB [ \-\-disable-cluster ]
 .RB [ \-\-enable-cluster ]
-.RB [ \-\---enable-halvm ]
-.RB [ \-\---disable-halvm ]
+.RB [ \-\-enable-halvm ]
+.RB [ \-\-disable-halvm ]
 .RB [ \-\-file
 .RI < configfile >]
 .RB [ \-\-lockinglib


