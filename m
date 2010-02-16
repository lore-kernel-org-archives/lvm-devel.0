From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 16 Feb 2010 14:39:42 -0500
Subject: [PATCH 0/7] Add vg/lv tag addition/deletion to lvm2app
Message-ID: <1266349189-23166-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset adds lv/vg tag addition/deletion to lvm2app.
pv tags will be handled later when the pv refactoring patches
are done.  Partially fixes rhbz 562909.

Patchset is fairly straightforward.  When adding a tag, we need
to copy the tag memory before adding it to the list (see patch #4).
The copy could be placed inside lvm2app or in the internal library.
I chose the internal library to minmize code in lvm2app.  Another
finer point is what to return when the 'get_tags' lvm2app function
is called but there's no tags - a NULL pointer or an empty list.
For now I've chosen a NULL pointer to avoid allocation of memory.
There is some inconsistency here in lvm2app but the behavior is
documented in the header for all functions that return lists.


