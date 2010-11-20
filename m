From: Dave Wysochanski <wysochanski@pobox.com>
Date: Fri, 19 Nov 2010 21:25:37 -0500
Subject: [PATCH 00/03] Add lvm2app functions to lookup an lv or pv handle
Message-ID: <1290219940-29464-1-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset implements helper functions to lookup an lv or pv handle
from vg handle and the pv|lv name or uuid.

Until now, users of lvm2app that wished to obtain an LV or PV handle from
an existing VG must do so by the following sequence:
1) Call lvm_vg_open() to open an existing VG
2) Call lvm_vg_list_{pvs|lvs}() to list all PVs or LVs
3) Find the PV or LV of interest by comparing uuids or names

The above method is awkward for callers of the API that wish to operate
on a single LV or PV.  This patchset should make it easier for callers
to do operations on a single LV or PV.


