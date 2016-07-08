From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:26:53 +0000 (UTC)
Subject: master - doc: mention group histogram restrictions in dmstats.8.in
Message-ID: <20160708182653.3F256610E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3caf4b80bbade402ba57c32090222214a9bc177
Commit:        c3caf4b80bbade402ba57c32090222214a9bc177
Parent:        db73d756e9481a867dd486e624eb1cba7c4def42
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jul 4 12:49:14 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

doc: mention group histogram restrictions in dmstats.8.in

---
 man/dmstats.8.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index b00ef88..def83ca 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -609,6 +609,9 @@ regions is given as a comma-separated list of region identifiers. A
 continuous range of identifers spanning from \fBR1\fP to \fBR2\fP may
 be expressed as '\fBR1\fP-\fBR2\fP'.
 
+Regions that have a histogram configured can be grouped: in this case
+the number of histogram bins and their bounds must match exactly.
+
 On success the group list and newly created \fBgroup_id\fP are
 printed to stdout.
 .


