From: saulery@free.fr <saulery@free.fr>
Date: Sat, 15 Nov 2014 17:46:27 +0100
Subject: Improve clvmd.8 manpage and help output
In-Reply-To: <1416069988-13208-1-git-send-email-saulery@free.fr>
References: <1416069988-13208-1-git-send-email-saulery@free.fr>
Message-ID: <1416069988-13208-3-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

Closer to the recommendation of groff_man (7) if possible

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 man/clvmd.8.in | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index d94d920..f639194 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -39,16 +39,16 @@ logging then the command needs to be issued twice, eg:
 .br
 .TP
 .BR "\-d" "[<" "\fIvalue\fP" ">]"
-Set debug logging level. \fIValue\fP can be:
-.br
-0: disabled;
-.br
-1: sends debug logs to stderr (implies \fB\-f\fP);
-.br
-2: sends debug logs to
-.BR syslog "(3).
-.br
-If \fB\-d\fP is specified without a \fIvalue\fP then 1 is assumed.
+Set debug logging level.If \fB\-d\fP is specified without a \fIvalue\fP then 1
+is assumed. \fIValue\fP can be:
+.RS
+.IP \fI0\fP
+Disabled;
+.IP \fI1\fP
+Sends debug logs to stderr (implies \fB\-f\fP);
+.IP \fI2\fP
+Sends debug logs to \fBsyslog\fP(3).
+.RE
 .TP
 .BR "\-E" "<" "\fIlock uuid\fP" ">"
 Pass \fIlock uuid\fP to be reacquired exclusively when \fBclvmd\fP is restarted.
-- 
2.1.3


