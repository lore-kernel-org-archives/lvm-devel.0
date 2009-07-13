From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 13 Jul 2009 03:09:47 -0400
Subject: [PATCH 0/4] Remove READ_REQUIRE_RESIZEABLE
Message-ID: <1247468991-13691-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


The following patchset remove READ_REQUIRE_RESIZEABLE vg_read flag by moving
the check inside specific library functions.  At the time of vg_read(),
we cannot know whether the user will want to resize or not.  The check
for this flag needs to be in the various functions that actually do the
resizing of the VG.

Nightly tests passes and applies cleanly on:
commit 1ed598ada6fabade22c680ef57e3fbd9a608ea91
Author: Dave Wysochanski <dwysocha@redhat.com>
Date:   Fri Jul 10 21:19:37 2009 +0000

    Remove unused code vg_lock_and_read() and related flags.
    
    Author: Dave Wysochanski <dwysocha@redhat.com>


