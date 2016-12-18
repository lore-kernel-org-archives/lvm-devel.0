From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 13:09:55 +0000 (UTC)
Subject: master - man: fix 'dmstats <command>' formatting in dmstats.8.in
Message-ID: <20161218130955.3406160EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25dd3988c3a5bed78f8f5c76ca2b24a7c95866a2
Commit:        25dd3988c3a5bed78f8f5c76ca2b24a7c95866a2
Parent:        35791689ba5ef95da45290fd12ce9cff55c86258
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 10:11:02 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 10:12:45 2016 +0000

man: fix 'dmstats <command>' formatting in dmstats.8.in

---
 man/dmstats.8.in |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 2367b8b0..7f451fd 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -53,12 +53,14 @@ dmstats \(em device-mapper statistics management
 .de CMD_COMMAND
 .  ad l
 .  IR command
-.  RI [ device_name
-.  RB | \-\-uuid
-.  IR uuid | \fB\-\-major
+.  RI [ device_name |
+.  RB [ \-u | \-\-uuid
+.  IR uuid ]
+.  RB | [ \-\-major
 .  IR major
 .  BR \-\-minor
 .  IR minor ]
+.  RB \%[ \-v | \-\-verbose]
 .  ad b
 ..
 .CMD_COMMAND


