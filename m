From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 20 Aug 2015 17:07:08 +0000 (UTC)
Subject: master - cmirrord manual: add --foreground and --help options
Message-ID: <20150820170708.55A5860182@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8821cc416e8a295f47c49cad060727a69769eaf5
Commit:        8821cc416e8a295f47c49cad060727a69769eaf5
Parent:        92a4b5cc3c83e1ef24092b826722ffa0e90eb697
Author:        Ferenc W??gner <wferi@niif.hu>
AuthorDate:    Wed Jul 8 14:41:24 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Aug 20 19:06:47 2015 +0200

cmirrord manual: add --foreground and --help options

---
 man/cmirrord.8.in |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/man/cmirrord.8.in b/man/cmirrord.8.in
index 8ef6794..383db65 100644
--- a/man/cmirrord.8.in
+++ b/man/cmirrord.8.in
@@ -3,7 +3,7 @@
 cmirrord \(em cluster mirror log daemon
 
 .SH SYNOPSIS
-.B cmirrord
+\fBcmirrord\fR [\fB\-f\fR] [\fB\-h\fR]
 
 .SH DESCRIPTION
 cmirrord is the daemon that tracks mirror log information in a cluster.
@@ -24,6 +24,12 @@ there are still active cluster mirrors, however, the signal will be
 ignored.  Active cluster mirrors should be shutdown before stopping the
 cluster mirror log daemon.
 
+.SH OPTIONS
+.IP "\fB\-f\fR, \fB\-\-foreground\fR" 4
+Do not fork and log to the terminal.
+.IP "\fB\-h\fR, \fB\-\-help\fR" 4
+Print usage.
+
 .SH SEE ALSO
 .BR lvm (8)
 .BR clvmd (8)


