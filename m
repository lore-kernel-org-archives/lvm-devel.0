From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Jul 2020 16:00:23 +0000 (GMT)
Subject: master - integrity: allow type option to be set when changing mirrors
Message-ID: <20200715160023.CCB533840C1C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=119d5947881a8b99640d81592986e508e040766d
Commit:        119d5947881a8b99640d81592986e508e040766d
Parent:        4667c4b35be03ad0dd6b0dc5aac65ac516af0a0b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 15 10:57:05 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 15 10:57:05 2020 -0500

integrity: allow type option to be set when changing mirrors

Allow the optional '--type raid1' to be included in the lvconvert
command when adding or removing raid images with integrity.
It does not change the meaning of the command (specifying a type
that matches the current type is redundant but generally allowed.)
---
 tools/command-lines.in | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 0051b77b5..e38b6e62f 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -359,7 +359,8 @@ OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to raid or change raid layout
 DESC: (a specific raid level must be used, e.g. raid1).
-RULE: all not lv_is_locked lv_is_pvmove lv_is_raid_with_integrity
+RULE: all not lv_is_locked lv_is_pvmove
+RULE: lv_is_raid_with_integrity not --stripes_long --stripesize --regionsize --interval
 
 lvconvert --mirrors SNumber LV
 OO: --regionsize RegionSize, --interval Number, --mirrorlog MirrorLog, OO_LVCONVERT


