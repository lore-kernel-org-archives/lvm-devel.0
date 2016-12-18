From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 13:09:57 +0000 (UTC)
Subject: master - man: fix 'dmstats list' option formatting in dmstats.8.in
Message-ID: <20161218130957.4683060EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14be8c4fad7cd50cbd0006b6824552733f40bafd
Commit:        14be8c4fad7cd50cbd0006b6824552733f40bafd
Parent:        25dd3988c3a5bed78f8f5c76ca2b24a7c95866a2
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 10:12:56 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 10:12:56 2016 +0000

man: fix 'dmstats list' option formatting in dmstats.8.in

---
 man/dmstats.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 7f451fd..5ee02a9 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -155,7 +155,7 @@ dmstats \(em device-mapper statistics management
 .  OPT_OBJECTS
 .  RB \%[ \-\-nosuffix ]
 .  RB [ \-\-notimesuffix ]
-.  RB \%[ \-v | \-\-verbose [ \-v | \-\-verbose ]]
+.  RB \%[ \-v | \-\-verbose]
 .  ad b
 ..
 .CMD_LIST


