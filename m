From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:24 -0400
Subject: [PATCH 00/14] Add lvm lv properties and lvm2app interfaces for pv/vg/lv.
Message-ID: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset is adds lv properties for lvm2app, and adds
the lvm2app interfaces and interactive tests to exercise
the interface.

A few attributes require more complex refactoring and are thus still
missing:
1. readahead: lv_read_ahead, lv_kernel_read_ahead
2. percents: snap_percent and copy_percent

All vg and pv properties and most lv properties may now be queried
with this patchset.


