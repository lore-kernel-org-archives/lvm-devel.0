From: Peter Rajnoha (@prajnoha) <gitlab@mg.gitlab.com>
Date: Wed, 30 Aug 2023 16:37:57 +0000
Subject: [Git][lvmteam/lvm2][main] man: dmsetup: document --headings
Message-ID: <64ef7065b8fbe_2810858d07454d@gitlab-sidekiq-low-urgency-cpu-bound-v2-77d478b54c-ql4c4.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Peter Rajnoha pushed to branch main at LVM team / lvm2


Commits:
092f58a7 by Peter Rajnoha at 2023-08-30T18:37:18+02:00
man: dmsetup: document --headings

- - - - -


1 changed file:

- man/dmsetup.8_main


Changes:

=====================================
man/dmsetup.8_main
=====================================
@@ -86,12 +86,11 @@ dmsetup \(em low level logical volume management
 .  IR count ]
 .  RB [ --interval
 .  IR seconds ]
-.  RB [ --noheadings ]
+.  RB [ --noheadings | --headings ]
 .  RB [ -o
 .  IR fields ]
 .  RB [ -O | --sort
 .  IR sort_fields ]
-.  RB [ --idsinheadings ]
 .  RB [ --nameprefixes ]
 .  RB [ --separator
 .  IR separator ]
@@ -503,10 +502,6 @@ Specify the minor number.
 When creating a device, don't load any table.
 .
 .TP
-.B --idsinheadings
-Show column identifiers instead of names in report output headings.
-.
-.TP
 .B --nameprefixes
 Add a "DM_" prefix plus the field name to the output.  Useful with
 \fB--noheadings\fP to produce a list of
@@ -520,6 +515,13 @@ rules).
 Suppress the headings line when using columnar output.
 .
 .TP
+.BR --headings " " none | abbrev | full | 0 | 1 | 2
+Type of headings line to use for columnar output.
+\fBnone\fP or \fB0\fP: No headings.
+\fBabbrev\fP or \fB1\fP: Column name abbreviations.
+\fBfull\fP or \fB2\fP: Full column names.
+.
+.TP
 .B --noflush
 Do not flush outstanding I/O when suspending a device, or do not
 commit thin-pool metadata when obtaining thin-pool status.



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/092f58a76216f35bb98e08ded14a75a915a4ed96

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/092f58a76216f35bb98e08ded14a75a915a4ed96
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230830/cc069719/attachment.htm>
