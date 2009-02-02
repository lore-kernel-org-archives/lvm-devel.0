From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:49:56 -0500
Subject: [PATCH 0/13] liblvm initialization, attribute, and object handling
Message-ID: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This is the latest in a series of liblvm patches involving the init code cleanup
as well as attribute and object handling code.  Patches are being developed
and reviewed by Thomas Woerner and myself.

I've begun to incorporate the latest vg_read() patches from Petr.
Note the "vg_open()" / "vg_close()" patches, which is a possible way we might
simplify some of those flags on vg_read() (an open/read/close sequence).
Patches are incomplete though I thought I'd throw it out for discussion.


