From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 00:05:45 -0400
Subject: [PATCH 0/8] Add implicit pvcreate to vgcreate and vgextend
Message-ID: <1248235553-13519-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


The following 8 patches add implicit pvcreate support to vgcreate and
vgextend.  This series is a rebase + improvements of a prior series
submitted last November:
http://www.redhat.com/archives/lvm-devel/2008-November/msg00072.html

This series does not address all the prior feedback but it does work.
Addressing the feedback will require further patches and refactoring.

Passes test suite and applies cleanly on top of:
commit 02f858e5c9843996591e87dfa60319d470365589
Author: Dave Wysochanski <dwysocha@redhat.com>
Date:   Wed Jul 22 03:13:57 2009 +0000

    Update test/api/vgtest.c to use lvm_errno and lvm_errmsg.
    


