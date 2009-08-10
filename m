From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 10 Aug 2009 14:08:21 -0400
Subject: [PATCH 0/4]: Change semantics of lvm_vg_remove and rename vg_remove fns
Message-ID: <1249927705-28528-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset changes the semantics of lvm_vg_remove to be more consistent with
lvm_vg_create, and renames some of the internal lvm library vg_remove functions.

For liblvm, we would like a consistent API that allows modification of LVM
objects in memory before committing to disk.  The commit to disk is normally
done in a single call, lvm_vg_write().  Currently, not all liblvm functions
behave this way, and lvm_vg_remove is one of them, as it commits to disk after
completion and does not require lvm_vg_write.  This is inconsistent with
lvm_vg_create, which requires lvm_vg_write to commit to disk.  This patchset
changes the semantic of lvm_vg_remove to require lvm_vg_write to commit to
disk and make it consistent with lvm_vg_create and other functions.  Along
the way, there are a few renames and minor refactorings to the internal
vg_remove functions.

Further cleanup should probably consolidate the various areas where devices are
removed from VGs as there is currently a bit of duplicated code.  I've avoided
such changes in this patchset though to keep it as simple and low risk.

Testsuite ok and applies cleanly on:
commit 597986b711175bd90d234e0a6ac001f165aa1274
Author: Dave Wysochanski <dwysocha@redhat.com>
Date:   Mon Aug 10 17:23:04 2009 +0000

    Update man pages to clarify usage of PE ranges.


