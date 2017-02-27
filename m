From: David Teigland <teigland@sourceware.org>
Date: Mon, 27 Feb 2017 17:35:42 -0500
Subject: master - commands: fix lvconvert raid rule
Message-ID: <201702272235.v1RMZgt4004596@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=998151e83e5f1673266ffad213a35b377c3a999b
Commit:        998151e83e5f1673266ffad213a35b377c3a999b
Parent:        8d0df0c011f23095cf028c556db15b531ca91ea5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 27 16:33:38 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 27 16:33:38 2017 -0600

commands: fix lvconvert raid rule

Recent rule change was incorrect.
We want to allow 'lvconvert --type raid' on raid1 LVs.
---
 tools/command-lines.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index f8e0db7..3105966 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -347,7 +347,7 @@ OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to raid or change raid layout.
 RULE: all not lv_is_locked lv_is_pvmove
-RULE: LV_raid not LV_raid0 LV_raid1
+RULE: LV_raid not LV_raid0
 
 lvconvert --mirrors SNumber LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog


