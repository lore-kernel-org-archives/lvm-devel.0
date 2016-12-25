From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 25 Dec 2016 17:37:27 +0000 (UTC)
Subject: master - man: fix name of 'write_time' field in dmstats.8.in
Message-ID: <20161225173727.8668660FF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e75f0b7c771ac6b3a2925af92a9f3098fa8381a7
Commit:        e75f0b7c771ac6b3a2925af92a9f3098fa8381a7
Parent:        96a1943fb8d208aa84c386cf48f2b62038b09e2e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 25 17:36:35 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 25 17:36:35 2016 +0000

man: fix name of 'write_time' field in dmstats.8.in

---
 man/dmstats.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index fbc7811..c3ede01 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -878,7 +878,7 @@ Count of writes merged this interval.
 .B write_sector_count
 Count of 512 byte sectors written this interval.
 .TP
-.B write_nsecs
+.B write_time
 Accumulated duration of all write requests (ns).
 .TP
 .B in_progress_count


