From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 10 Feb 2017 17:12:20 +0000 (UTC)
Subject: master - man: mention dmstats in lvmsar and lvmsadc man pages
Message-ID: <20170210171220.5E71160640@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68ec6940e6897192aec6480a14492a5adc6937d8
Commit:        68ec6940e6897192aec6480a14492a5adc6937d8
Parent:        55eaabd1183042b8e03b3a969eadf624623c4b62
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Feb 10 17:07:39 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Feb 10 17:09:17 2017 +0000

man: mention dmstats in lvmsar and lvmsadc man pages

---
 man/lvmsadc.8.in |    5 ++++-
 man/lvmsar.8.in  |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/man/lvmsadc.8.in b/man/lvmsadc.8.in
index e156de2..81d2b66 100644
--- a/man/lvmsadc.8.in
+++ b/man/lvmsadc.8.in
@@ -7,7 +7,10 @@ lvmsadc \(em LVM system activity data collector
 .B lvmsadc
 
 .SH "DESCRIPTION"
-lvmsadc is not currently supported under LVM2.
+lvmsadc is not currently supported under LVM2: the device-mapper statistics
+facility provides similar performance metrics using the \fBdmstats(8)\fP
+command.
 
 .SH "SEE ALSO"
+.BR dmstats (8)
 .BR lvm (8)
diff --git a/man/lvmsar.8.in b/man/lvmsar.8.in
index a9a6132..fca111f 100644
--- a/man/lvmsar.8.in
+++ b/man/lvmsar.8.in
@@ -7,7 +7,10 @@ lvmsar \(em LVM system activity reporter
 .B lvmsar
 
 .SH "DESCRIPTION"
-lvmsar is not currently supported under LVM2.
+lvmsar is not currently supported under LVM2: the device-mapper statistics
+facility provides similar performance metrics using the \fBdmstats(8)\fP
+command.
 
 .SH "SEE ALSO"
+.BR dmstats (8)
 .BR lvm (8)


