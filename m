From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 19 Mar 2010 21:06:16 +0000
Subject: Don't allow resizing of internal logical volumes
In-Reply-To: <20100319200807.GC7345@redhat.com>
References: <Pine.LNX.4.64.1003181950140.29893@hs20-bc2-1.build.redhat.com>
	<20100319200807.GC7345@redhat.com>
Message-ID: <20100319210616.GI919@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> > Note that test for VISIBLE_LV is not sufficient because snapshot0 volumes
> > have the VISIBLE_LV flag set. So we test the name instead of the flags.
 
We only test against flags.
The code should be the same as other code in toollib.
(We do actually allow LVs with reserved names to be changed if the use
of the reserved name pre-dates the introduction of the restriction.  The
reserved names validation is only used on *newly-supplied* LV names, not
pre-existing ones.  Well that's how it was meant to work, anyway...)

Alasdair


