From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Feb 2010 12:28:56 -0500
Subject: [PATCH 0/8] Add vg/lv tag addition/deletion to lvm2app, v2
Message-ID: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This is a second iteration of the lv/vg tag add/delete to lvm2app.
pv tags will be handled later when the pv refactoring patches
are done since they need the pv->vg link for the vgmem handle.
Partially fixes rhbz 562909.

Changes since last set:
1) Address all feedback; change return of 'get' fns to NULL if problem
obtaining list, empty list if no tags; use dm_pool_strdup, return_0, etc
2) Patch #5, Add tag_list_copy() supporting function; re-use code that
duplicates the tag list


