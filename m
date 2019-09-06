From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 6 Sep 2019 08:16:45 -0400
Subject: master - lvchange: add --resync help/manual text relative to 'R' attribute
Message-ID: <201909061216.x86CGjQY013245@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddf7c95470eb00f47446f6bbf3ba7b3efb8e43db
Commit:        ddf7c95470eb00f47446f6bbf3ba7b3efb8e43db
Parent:        acb8050a30fb61ce5188d5c6daa8177942da0538
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Sep 6 14:08:29 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Sep 6 14:16:27 2019 +0200

lvchange: add --resync help/manual text relative to 'R' attribute

Add information that --resync clears the 'R' attribute
on not initially synchronized mirrror/RAID LVs.

Related: 1708299
---
 tools/command-lines.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index f914650..1169224 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -261,6 +261,7 @@ OO: --activate Active, OO_LVCHANGE
 IO: --ignoreskippedcluster
 ID: lvchange_resync
 DESC: Resyncronize a mirror or raid LV.
+DESC: Use to reset 'R' attribute on a not initially synchronized LV.
 RULE: all not lv_is_pvmove lv_is_locked
 RULE: all not LV_raid0
 


