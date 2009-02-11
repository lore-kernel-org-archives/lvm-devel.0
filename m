From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Tue, 10 Feb 2009 21:49:08 -0800
Subject: lvm2: warning after mirrored LV is initialized as PV
In-Reply-To: <49924582.3040708@redhat.com>
References: <49924582.3040708@redhat.com>
Message-ID: <20090211054908.GA23806@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui [tyasui at redhat.com] wrote:
> Jonathan Brassow wrote (in dm-devel)
> > Note that once you get #1 done you /should/ be able to get a mirrored  
> > log by:
> > prompt> lvcreate -m1 --mirrorlog core -l 1 -n mirrored_log vg
> > prompt> lvcreate -m1 -L 5G -n mirror vg /dev/sdb /dev/sdc /dev/vg/ 
> > mirrored_log
> 
> I'm now evaluating the layered LV approach, which was suggested by Jon,
> with the latest LVM command (2.02.45), but some warning messages are
> displayed after mirrored LV was initialized as PV.

Jonathan and Alasdair explained what they mean by 'generic layering' in
one of the DM/multipath Monday meetings.  Currently allocations are done
from PV's. They want to include LV's in the allocation map. This
requires changes in the allocation path. We probably want to designate
these LVs to avoid admin mistakes. With the above changes in place, we
don't need to include LVs as PVs at all.

The changes also require additional options and arguments to exiting
commands.

If you don't include LVs as PVs, you don't get any warnings you listed!


