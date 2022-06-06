From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 6 Jun 2022 11:00:35 +0200
Subject: lvmthin with dedicated lvols for data/md
In-Reply-To: <CAFe+wq1xiT7TQyy9CPmgtseZ_0+umaNLEXkJC9vXW9xCZDY5pA@mail.gmail.com>
References: <CAFe+wq0kVFovJP7YdkJ3yY0oqdSAHM-St_LbbUFN2dNx6V6gAA@mail.gmail.com>
 <CAFe+wq1xiT7TQyy9CPmgtseZ_0+umaNLEXkJC9vXW9xCZDY5pA@mail.gmail.com>
Message-ID: <b269f0e9-f2a1-f89d-62ee-766d99dee45b@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 06. 06. 22 v 6:18 Lakshmi Narasimhan Sundararajan napsal(a):
> I found the reason for the above behavior.
> For the benefit of anyone looking into this, there is an internal spare 
> volume for metadata that gets created.
> So using 50%PVS for the metadata volume will create a spare of equal size.


Correct -? _pmspare volume is created together with the first pool in VG and 
should have be always the max size of any metadata volume in this VG. But you 
could use '---poolmetadataspare n' if you want to handle recovery yourself 
(and you could also 'lvremove' such _pmspare LV at any time.

It's worth to note max size of metadata LV is ~16GiB.

>
> My one follow up question to experts here would be, what happens when in 
> future metadata volume gets full.
> Should both the spare and metadata volume be extended equally?


Yes - lvm2 tries to extend '_pmspare' if it's possible to match biggest 
metadata LV in VG.


> Currently I see that one can extend the metadata volume independently, this 
> leaves the spare volume with the original capacity.
> Will such differing sized volume for metadata and spare leave recovery useless?
> Please suggest the correct approach to resizing metadata volumes.


pmspare is useful for 'recovery' cases - i.e. you need a new LV to repair 
metadata (as there is no 'in-place' recovery) .


> ? [pxpool_tdata] ?test Twi-ao---- <9.99g
> ? [pxpool_tmeta] ?test ewi-ao---- <4.66g


Your 'meta' size is certainly too big for your 'data' size - the main idea is 
that metadata LV is a small fraction of data size, but once you get familiar 
with thinpool - you will most likely figure this out.

Regards


Zdenek


