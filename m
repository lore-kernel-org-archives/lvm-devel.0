From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Fri, 9 Oct 2009 10:56:47 -0700
Subject: Re: [PATCH 0 of 10] LVM: Mirrored log support
In-Reply-To: <1255036474.12319.16.camel@hydrogen.msp.redhat.com>
References: <1255036474.12319.16.camel@hydrogen.msp.redhat.com>
Message-ID: <20091009175647.GA7737@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow [jbrassow at redhat.com] wrote:
> These patches are a replacement to the proposed patches - a fresh start.
> They address a couple problems that I saw with the old patches: 1)
> Allocation policies are respected and behave the same as today for other
> log types.
> 2) The on-disk layout of the previous version - when given only two
> disks to allocate from - would put the log on the front of one device
> and the back of another.  This virtually ensures a performance hit.
> These patches put the logs in the same place WRT the images.
> 3) The new patches reduce parameter bloat.  I think the previous patches
> required the extra parameters because they were using functions deep in
> the code that were from higher levels... adding parameters and
> "spaghettifying" the code.

Thank you, Jonathan. I tested creating mirrored volumes with the new
patchset and was able to activate/deactivate with the old patchset and
vice-versa. I was able to create mirrored volumes with new patchset and
was able to activate/deactivate with the virgin 2.02.53 LVM code.
 
> These patches should be considered a starting point.  While 'lvcreate'
> works, 'lvconvert' does not handle all transitions.  In fact,
> 'lvconvert' will only handle 'core' -> 'disk/redundant' and
> 'disk/redundant' -> 'core'.  It will not handle 'disk' <-> 'redundant'.

I haven't tried these, will try next. Initially, I thought anyone
wishing to go from 'disk' to 'redundant' can go to 'disk -> core' and
then 'core -> redundant'. The only problem is they may lose the 'sync'
status and the second conversion may sync the mirror data. We can either
choose to support 'disk <-> redundant' OR supply '--nosync' option to
lvconvert. What do you think?

Thank you again for the patchset.

--Malahal.


