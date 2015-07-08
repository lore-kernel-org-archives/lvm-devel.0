From: Ferenc Wágner <wferi@niif.hu>
Date: Wed,  8 Jul 2015 14:41:24 +0200
Subject: [PATCH 3/6] cmirrord: document the --foreground and --help options
In-Reply-To: <1436359287-6682-1-git-send-email-wferi@niif.hu>
References: <1436359287-6682-1-git-send-email-wferi@niif.hu>
Message-ID: <1436359287-6682-4-git-send-email-wferi@niif.hu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 man/cmirrord.8.in |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/man/cmirrord.8.in b/man/cmirrord.8.in
index 8ef6794..8ea2ba9 100644
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
+Do not daemonize and log to the terminal.
+.IP "\fB\-h\fR, \fB\-\-help\fR" 4
+Print usage.
+
 .SH SEE ALSO
 .BR lvm (8)
 .BR clvmd (8)
-- 
1.7.10.4


