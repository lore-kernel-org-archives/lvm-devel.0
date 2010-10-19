From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 00:02:23 -0400
Subject: [PATCH 00/08] Add lvm lv properties for lvm2app.
Message-ID: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset adds remaining lv properties for lvm2app, and adds
the lvm2app interfaces and interactive tests to exercise
the interface.

Changes since last patchset:
1. Added readahead attributes (lv_read_ahead, lv_kernel_read_ahead)
2. Incorporated most all Petr and Kabi's feedback comments, including
renaming of the fields, etc.  I did not change the 'get' function
prototype to return the property value rather than passing it in.
I will do this as a second patchset.
3. Updated comments describing new APIs in lvm2app.h

The only two lv properties not included now are still the float/percent
based properties, snap_percent and copy_percent.  These should be
refactored carefully and I did not want to delay these patches further.

All vg and pv properties and most lv properties may now be queried
with this patchset.


