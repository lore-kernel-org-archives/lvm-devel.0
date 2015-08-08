From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat,  8 Aug 2015 16:50:19 +0000 (UTC)
Subject: master - WHATS_NEW_DM: Update for preliminary stats commits
Message-ID: <20150808165019.1956C610FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f06d866110938458ed736f927e859534c99c295e
Commit:        f06d866110938458ed736f927e859534c99c295e
Parent:        3638c05ec95e0fa445f06b05567189b712a0b8a9
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Aug 8 17:37:07 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Aug 8 17:48:30 2015 +0100

WHATS_NEW_DM: Update for preliminary stats commits

Add entries for dm_report_column_headings() and report row leaks
and remove the dm_report interval/wait entry.
---
 WHATS_NEW_DM |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c0cdadc..598a354 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,9 +1,10 @@
 Version 1.02.104 -
 =================================
+  Add support to redisplay column headings for repeating column reports.
+  Fix report header and row resource leaks.
   Report timestamps of ioctls with dmsetup -vvv.
   Recognize report field name variants without any underscores too.
   Add dmsetup --interval and --count to repeat reports at specified intervals.
-  Add report interval and waiting functions to libdevmapper.
   Add dm_timestamp functions to libdevmapper.
 
 Version 1.02.103 - 24th July 2015


