From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  2 Sep 2015 20:03:32 +0000 (UTC)
Subject: master - man: document --regionid in dmstats.8.in
Message-ID: <20150902200332.C690360FDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=341460178871140500cf14c89022e013ced943d5
Commit:        341460178871140500cf14c89022e013ced943d5
Parent:        d31c4e0bc12fb673d4b30ba8846eec8e27ae6276
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Sep 2 20:35:43 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Sep 2 21:03:03 2015 +0100

man: document --regionid in dmstats.8.in

---
 man/dmstats.8.in |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 69ba2a3..3ffd534 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -1,4 +1,4 @@
-.TH DMSTATS 8 "Jul 25 2015" "Linux" "MAINTENANCE COMMANDS"
+eTH DMSTATS 8 "Jul 25 2015" "Linux" "MAINTENANCE COMMANDS"
 .SH NAME
 dmstats \(em device-mapper statistics management
 .SH SYNOPSIS
@@ -223,6 +223,9 @@ string is stored with the region. Subsequent operations may supply a
 program ID in order to select only regions with a matching value. The
 default program ID for dmstats-managed regions is "dmstats".
 .TP
+.BR \-\-regionid \fIid
+Specify the region to operate on.
+.TP
 .BR \-\-relative
 If displaying the histogram report show relative (percentage) values
 instead of absolute counts.


