From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 13 Jul 2009 00:12:33 -0400
Subject: [PATCH 0/5] Implement liblvm vgcreate/vgremove and related APIs
Message-ID: <1247458358-24590-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


The following patchset implements enough of the liblvm VG APIs to get the
first of the unit test sequences completed as discussed in Berlin.  The unit
test involves a simple vgcreate/vgextend/vgremove sequence and uses the
following liblvm APIs: lvm_create, lvm_destroy, lvm_vg_create, lvm_vg_extend,
lvm_vg_set_extent_size, lvm_vg_write, lvm_vg_remove, and lvm_vg_close.

Unit test passes (provided hardcoded values are free) and applies cleanly on:
commit 1ed598ada6fabade22c680ef57e3fbd9a608ea91
Author: Dave Wysochanski <dwysocha@redhat.com>
Date:   Fri Jul 10 21:19:37 2009 +0000

    Remove unused code vg_lock_and_read() and related flags.
    
    Author: Dave Wysochanski <dwysocha@redhat.com>


