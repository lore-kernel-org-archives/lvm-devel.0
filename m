From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 16 Feb 2009 20:25:08 +0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c
In-Reply-To: <20090206124152.28686.qmail@sourceware.org>
References: <20090206124152.28686.qmail@sourceware.org>
Message-ID: <20090216202508.GB26197@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Feb 06, 2009 at 12:41:52PM -0000, mbroz at sourceware.org wrote:
> 	Fix pvs segfault when pv mda attributes requested for not available PV.
 
Ack.

> -	info = info_from_pvid(pvid, 0);

Have you reviewed all instances of this throughout the tree, now that it is
acceptable for disks to be missing?

Alasdair


