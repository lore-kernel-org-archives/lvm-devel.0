From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 23 Nov 2014 23:03:16 +0000 (UTC)
Subject: master - man/lvm.conf: Update to reflect changes in config parser.
Message-ID: <20141123230316.8F30F6055D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1445a74d76ddf59043e0e713c6a96eddc4839670
Commit:        1445a74d76ddf59043e0e713c6a96eddc4839670
Parent:        14472d62ba459db629221e83235720dde7fc4e49
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Nov 23 23:41:58 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 23 23:41:58 2014 +0100

man/lvm.conf: Update to reflect changes in config parser.

---
 man/lvm.conf.5.in |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 5bc2081..288bc42 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -114,7 +114,9 @@ A value can either be a new section, or an assignment.
 .TP
 .BR section " = " identifier " '" { "' " value "* '" } '
 .br
-A section is groups associated values together.
+A section groups associated values together. If the same section is
+encountered multiple times, the contents of all instances are concatenated
+together in the order of appearance.
 .br
 It is denoted by a name and delimited by curly brackets.
 .br
@@ -126,9 +128,13 @@ e.g.	backup {
 .TP
 .BR assignment " = " identifier " '" = "' ( " array " | " type " )"
 .br
-An assignment associates a type with an identifier.
+An assignment associates a type with an identifier. If the identifier contains
+forward slashes, those are interpreted as path delimiters. The statement
+\fBsection/key = value\fP is equivalent to \fBsection { key = value }\fP. If
+multiple instances of the same key are encountered, only the last value is used
+(and a warning is issued).
 .br
-e.g.	level = 7
+e.g.	\fBlevel = 7\fP
 .br
 .TP
 .BR array " =  '" [ "' ( " type " '" , "')* " type " '" ] "' | '" [ "' '" ] '
@@ -146,7 +152,8 @@ An empty array is acceptable.
 .br
 .B string \fR= '\fB"\fR'.*'\fB"\fR'
 .IP
-Strings must be enclosed in double quotes.
+Strings with spaces must be enclosed in double quotes, single words that start
+with a letter can be left unquoted.
 
 .SH SECTIONS
 .LP


