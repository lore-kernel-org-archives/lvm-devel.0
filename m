From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 11 Dec 2014 14:50:52 +0000 (UTC)
Subject: master - man: put back the --binary reference in {pv, vg, lv}display man page
Message-ID: <20141211145052.BA7F960C9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e905d454058ef17bbb2b9758c59a5505d1c95be
Commit:        2e905d454058ef17bbb2b9758c59a5505d1c95be
Parent:        3b02ccd2011c058f01c3acce76c599f3a39408e7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 11 15:50:37 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 11 15:50:37 2014 +0100

man: put back the --binary reference in {pv,vg,lv}display man page

---
 man/lvdisplay.8.in |    1 +
 man/pvdisplay.8.in |    1 +
 man/vgdisplay.8.in |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 1881b3f..3232853 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -25,6 +25,7 @@ lvdisplay \(em display attributes of a logical volume
 .B lvdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
+.RB [ \-\-binary ]
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 0399c1e..70c9bfc 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -26,6 +26,7 @@ pvdisplay \- display attributes of a physical volume
 .B pvdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
+.RB [ \-\-binary ]
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 97cb314..1e472d3 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -26,6 +26,7 @@ vgdisplay \(em display attributes of volume groups
 .B vgdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
+.RB [ \-\-binary ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]


