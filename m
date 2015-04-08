From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Apr 2015 09:15:02 +0000 (UTC)
Subject: master - select: mention { } use in lvm.8 man page and '-S help' properly
Message-ID: <20150408091502.19F66616B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f32973c78e981226577e88db662a285ea6c11bd5
Commit:        f32973c78e981226577e88db662a285ea6c11bd5
Parent:        8fdca0de7910052594a55bfb7bd3815afe701dad
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 8 11:14:16 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 8 11:14:16 2015 +0200

select: mention { } use in lvm.8 man page and '-S help' properly

---
 libdm/libdm-report.c |    2 +-
 man/lvm.8.in         |   10 +++++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6f528f1..9f50ff3 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2612,7 +2612,7 @@ static void _display_selection_help(struct dm_report *rh)
 	log_warn("  size                - Floating point value with units, 'm' unit used by default if not specified.");
 	log_warn("  percent             - Non-negative integer with or without %% suffix.");
 	log_warn("  string              - Characters quoted by \' or \" or unquoted.");
-	log_warn("  string list         - Strings enclosed by [ ] and elements delimited by either");
+	log_warn("  string list         - Strings enclosed by [ ] or { } and elements delimited by either");
 	log_warn("                        \"all items must match\" or \"at least one item must match\" operator.");
 	log_warn("  regular expression  - Characters quoted by \' or \" or unquoted.");
 	log_warn(" ");
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 2faaba4..26d94ee 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -470,6 +470,10 @@ that can be used in selection, see the output of \fB<lvm reporting command> -S h
 \fB[\fP  \(em List start
 .IP
 \fB]\fP  \(em List end
+.IP
+\fB{\fP  \(em List subset start
+.IP
+\fB}\fP  \(em List subset end
 .LP
 \fBInformal grammar specification\fP:
 .IP
@@ -477,7 +481,11 @@ that can be used in selection, see the output of \fB<lvm reporting command> -S h
 .IP
 .BR VALUE " = " [VALUE " log_op " VALUE]
 .br
-For list-based types: string list. The log_op must always be of one type within the whole list value.
+For list-based types: string list. Matches strictly. The log_op must always be of one type within the whole list value.
+.IP
+.BR VALUE " = " {VALUE " log_op " VALUE}
+.br
+For list-based types: string list. Matches a subset. The log_op must always be of one type within the whole list value.
 .IP
 .BR VALUE " = " value
 .br


