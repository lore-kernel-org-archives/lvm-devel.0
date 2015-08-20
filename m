From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 20 Aug 2015 16:28:51 +0000 (UTC)
Subject: master - man: fix program_id string in dmstats.8.in
Message-ID: <20150820162851.1093C60B28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23770214a9ac844e72e62de589a4d61cd0e125bc
Commit:        23770214a9ac844e72e62de589a4d61cd0e125bc
Parent:        386e91addbaffcaae20f4f20084cb06b7374e402
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Aug 20 12:18:51 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Aug 20 17:27:28 2015 +0100

man: fix program_id string in dmstats.8.in

---
 man/dmstats.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 5c5f41c..bdcf742 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -266,7 +266,7 @@ stores an arbitrary string and is not used by dmstats or the
 device-mapper kernel statistics subsystem.
 
 By default dmstats creates regions with a \fBprogram_id\fP of
-"DMSTATS1".
+"dmstats".
 
 On success the \fBregion_id\fP of the newly created region is printed to
 stdout.


