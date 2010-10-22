From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 22 Oct 2010 07:51:05 -0400
Subject: [PATCH 00/05] Add generic property fns for lvm2app, return struct, v2.
Message-ID: <1287748270-26875-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is the modified patchset based on Petr's suggestion of changing
the return value from 'int' to struct lvm_property_value:
http://www.redhat.com/archives/lvm-devel/2010-October/msg00068.html

Returning the struct seems like the approach things are moving, but
a few details probably still worth considering, especially the exact
layout of the exported struct lvm_property_value (ABI implications).
Final submission might be best left to Petr.

Patchset adds the lvm2app 'get' functions for vg, pv, and lv, and interactive
tests to exercise the interface.

Changes since last patchset:
1. Added 'is_integer' bit/flag, similar to 'is_string'
2. Updated comments describing new APIs in lvm2app.h
3. Simplified the common code in lvm2app into a local 'get_property'
function which allows for a single-line implementation of
lvm_{pv|vg|lv}_get_property

The only two lv properties not included now are still the float/percent
based properties, snap_percent and copy_percent.  These should be
refactored carefully and I did not want to delay these patches further.

All vg and pv properties and most lv properties may now be queried
with this patchset.


