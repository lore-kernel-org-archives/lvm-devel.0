From: Dave Wysochanski <wysochanski@pobox.com>
Date: Thu, 11 Nov 2010 11:41:54 -0500
Subject: [PATCH 00/03] Add generic VG 'set' property function for lvm2app.
Message-ID: <1289493717-5790-1-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(Re-send.  For some reason this set did not hit lvm-devel last week.)

This small patchset implements a 'set' property function for lvm2app.
The 'set' function is only defined for certain 'settable' properties.
Initially, we only define it for vg_mda_copies, but future patches
can define a 'set' function for any property in one of the {pv|vg|lv}change
lvm functions.  In this way, we do not need separate lvm2app functions for
pvchange, lvchange, and vgchange, but can just allow the application to 'get'
and then 'set' the property.

Just cleaning out my remaining in-progress patches.


