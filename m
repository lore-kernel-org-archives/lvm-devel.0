From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 07:32:47 -0400
Subject: [PATCH 00/08] Add lvm lv properties for lvm2app, return struct.
Message-ID: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is the modified patchset based on Petr's suggestion of changing
the return value from 'int' to struct lvm_property_value:
http://www.redhat.com/archives/lvm-devel/2010-October/msg00068.html

I agree it is a good approach and so am posting it for comparison
with the previous approach and final decision.

Patchset adds remaining lv properties for lvm2app, and adds
the lvm2app 'get' interfaces for vg, pv, and lv, and interactive
tests to exercise the interface.

Changes since last patchset:
1. Added readahead attributes (lv_read_ahead, lv_kernel_read_ahead)
2. Incorporated most all feedback comments, including renaming of the
fields, etc.  I did not change the 'get' function prototype to return
the property value rather than passing it in.
3. Updated comments describing new APIs in lvm2app.h
4. Changed return value from 'int' to lvm_property_value based on
Petr's suggestion.  Added a 'is_valid' flag, which must be checked
before using the value.
5. Simplified the common code in lvm2app into a local 'get_property'
function which allows for a single-line implementation of
lvm_{pv|vg|lv}_get_property

The only two lv properties not included now are still the float/percent
based properties, snap_percent and copy_percent.  These should be
refactored carefully and I did not want to delay these patches further.

All vg and pv properties and most lv properties may now be queried
with this patchset.


