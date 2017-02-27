From: David Teigland <teigland@sourceware.org>
Date: Mon, 27 Feb 2017 18:08:58 -0500
Subject: master - commands: remove lvconvert raid rule
Message-ID: <201702272308.v1RN8wSB022460@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a14617dc4413911b3af0cfea38cd5c2fe45afa8
Commit:        4a14617dc4413911b3af0cfea38cd5c2fe45afa8
Parent:        f9d28f1aeccaa923dfe31fda982d2a5fd5ef0f2d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 27 17:06:08 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 27 17:06:08 2017 -0600

commands: remove lvconvert raid rule

A raid0 LV also needs to be converted to other
raid levels, so this rule should be removed entirely.
---
 tools/command-lines.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 3105966..26c2deb 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -347,7 +347,6 @@ OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to raid or change raid layout.
 RULE: all not lv_is_locked lv_is_pvmove
-RULE: LV_raid not LV_raid0
 
 lvconvert --mirrors SNumber LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog


