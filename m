From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 13:09:59 +0000 (UTC)
Subject: master - man: fix 'dmstats create' formatting in dmstats.8.in
Message-ID: <20161218130959.5FAC260EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f9d901c7142a0f2a73eb0353db992407187a144
Commit:        4f9d901c7142a0f2a73eb0353db992407187a144
Parent:        14be8c4fad7cd50cbd0006b6824552733f40bafd
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 10:23:12 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 10:23:12 2016 +0000

man: fix 'dmstats create' formatting in dmstats.8.in

---
 man/dmstats.8.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 5ee02a9..fbc7811 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -83,8 +83,8 @@ dmstats \(em device-mapper statistics management
 .  ad l
 .  BR create
 .  RB [ device_name...
-.  RB | file_path... ]
-.  RB [ \-\-alldevices ]
+.  RB | file_path...
+.  RB | [ \-\-alldevices ]]
 .  RB [ \-\-areas
 .  IR nr_areas | \fB\-\-areasize
 .  IR area_size ]


