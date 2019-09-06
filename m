From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 6 Sep 2019 08:19:53 -0400
Subject: stable-2.02 - lvchange: add --resync help/manual text relative to 'R' attribute
Message-ID: <201909061219.x86CJrT9013371@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c07c5482916d493caf951cac5b5b22af0620724
Commit:        1c07c5482916d493caf951cac5b5b22af0620724
Parent:        6b12930860a993624d6325aec2e9c561f4412aa9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Sep 6 14:08:29 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Sep 6 14:19:32 2019 +0200

lvchange: add --resync help/manual text relative to 'R' attribute

Add information that --resync clears the 'R' attribute
on not initially synchronized mirror/RAID LVs.

Related: 1708299
---
 tools/command-lines.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index b4a9896..342b43c 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -259,6 +259,7 @@ lvchange --resync VG|LV_raid_mirror|Tag|Select ...
 OO: --activate Active, OO_LVCHANGE
 ID: lvchange_resync
 DESC: Resyncronize a mirror or raid LV.
+DESC: Use to reset 'R' attribute on a not initially synchronized LV.
 RULE: all not lv_is_pvmove lv_is_locked
 RULE: all not LV_raid0
 


