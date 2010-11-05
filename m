From: Dave Wysochanski <wysochanski@pobox.com>
Date: Fri, 05 Nov 2010 20:36:16 -0000
Subject: [PATCH 0/3] Add generic VG 'set' property function for lvm2app.
Message-ID: <1288987522-13757-1-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This small patchset implements a 'set' property function for lvm2app.
The 'set' function is only defined for certain 'settable' properties.
Initially, we only define it for vg_mda_copies, but future patches
can define a 'set' function for any property in one of the {pv|vg|lv}change
lvm functions.  In this way, we do not need separate lvm2app functions for
pvchange, lvchange, and vgchange, but can just allow the application to 'get'
and then 'set' the property.

Just cleaning out my remaining in-progress patches.  Petr feel free to
take or leave as you wish.


