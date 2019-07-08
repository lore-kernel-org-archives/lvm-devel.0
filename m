From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 8 Jul 2019 13:33:51 -0400
Subject: master - lvconvert: allow --stripes/--stripesize in 'mirror' conversions
Message-ID: <201907081733.x68HXplD004848@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b63a219f4f9d7f2f6c5086375b96c3bd892a1a0
Commit:        1b63a219f4f9d7f2f6c5086375b96c3bd892a1a0
Parent:        fef8e506891bd159475de83f248fdac660675163
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jul 8 19:07:18 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jul 8 19:32:17 2019 +0200

lvconvert: allow --stripes/--stripesize in 'mirror' conversions

This allows the creation of a striped mirror leg(s) during upconvert
by adding lvconvert command line options --stripes/--stripesize
for 'mirror' to tools/command-lines.in.

In case multiple mirror legs are being added, all will have the
same requested striped layout.

Resolves: rhbz1720705
---
 tools/command-lines.in |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 73a1e64..f914650 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -343,13 +343,11 @@ DESC: Convert LV to striped.
 RULE: all not lv_is_locked lv_is_pvmove
 
 lvconvert --type mirror LV
-OO: --mirrors SNumber, --regionsize RegionSize, --interval Number, --mirrorlog MirrorLog, OO_LVCONVERT
+OO: --mirrors SNumber, --stripes_long Number, --stripesize SizeKB, --regionsize RegionSize, --interval Number, --mirrorlog MirrorLog, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to type mirror (also see type raid1),
-DESC: (also see lvconvert --mirrors).
 RULE: all not lv_is_locked lv_is_pvmove
-FLAGS: SECONDARY_SYNTAX
 
 # When LV is already raid, this changes the raid layout
 # (changing layout of raid0 and raid1 not allowed.)


