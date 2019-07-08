From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 8 Jul 2019 13:16:00 -0400
Subject: stable-2.02 - lvconvert: allow --stripes/--stripesize in 'mirror' conversions
Message-ID: <201907081716.x68HG0SB031288@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3c8cebd87f9bd7591529f3d65783cc6f1fd3f92
Commit:        e3c8cebd87f9bd7591529f3d65783cc6f1fd3f92
Parent:        2f846697fcb16b2e0954a051577bd47c8cf6721c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jul 8 19:07:18 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jul 8 19:14:11 2019 +0200

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
index a8c06ba..b4a9896 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -334,13 +334,11 @@ DESC: Convert LV to striped.
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


