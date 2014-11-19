From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Nov 2014 00:14:12 +0000 (UTC)
Subject: master - man: clvmd help output
Message-ID: <20141119001412.3A75D6033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5226181329fe9f810495cbc348942708dacc8d0e
Commit:        5226181329fe9f810495cbc348942708dacc8d0e
Parent:        10330b8782628d981b05de7c06da4370e4b34ff0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 18 22:07:58 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 19 01:09:52 2014 +0100

man: clvmd help output

Closer to the recommendation of groff_man (7) if possible

Signed-off-by: St??phane Aulery <saulery@free.fr>
---
 man/clvmd.8.in |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index d79c29b..915e447 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -26,17 +26,16 @@ if a node in the cluster does not have this daemon running.
 .SH OPTIONS
 .TP
 .BR \-d [< \fIvalue >]
-Enable debug logging. Value can be 0, 1 or 2.
-.br
-0 disables debug logging
-.br
-1 sends debug logs to stderr (implies \fB\-f\fP option)
-.br
-2 sends debug logs to syslog
-.br
-If
-.B \-d
-is specified without a value then 1 is assumed.
+Set debug logging level.If \fB\-d\fP is specified without a \fIvalue\fP 
+then 1 is assumed. \fIValue\fP can be:
+.RS
+.IP \fI0\fP
+Disabled
+.IP \fI1\fP
+Sends debug logs to stderr (implies \fB\-f\fP)
+.IP \fI2\fP
+Sends debug logs to \fBsyslog\fP(3)
+.RE
 .TP
 .B \-C
 Only valid if


