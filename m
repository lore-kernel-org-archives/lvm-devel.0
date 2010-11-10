From: Dave Wysochanski <wysochanski@pobox.com>
Date: Wed, 10 Nov 2010 11:11:53 -0500
Subject: [PATCH 0/7] Add lvm {lv|pv}seg properties for lvm2app.
Message-ID: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset adds APIs covering pv and lv segments properties.
New types are added which cover lists of lvsegs and pvsegs.
Functions lvm_pv_list_pvsegs() and lvm_lv_list_lvsegs() are added
which return a list of lvsegs and pvsegs, and lvm_{pv|lv}seg_get_property()
functions are added to query the properties.  Finally, interactive
tests are updated to cover lvseg and pvseg properties.

All lvseg properties are covered by this patchset, with the exception of
'seg_pe_ranges' and 'devices'.  All (2) pvseg properties are covered
by this patchset.

This patchset enumerates lvsegs from an lv_t and pvsegs from a pv_t.
The enumeration is consistent with other enumeration APIs already in
lvm2app (lvm_vg_list_lvs, lvm_vg_list_pvs, etc).

This patchset should apply cleanly on upstream and finishes the properties
patchset, with the exception of a couple specific 'get' functions for
lvseg_t ('seg_pe_ranges' and 'devices') and lv_t ('snap_percent' and
'copy_percent').


