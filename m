From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 02 Feb 2009 18:29:15 -0500
Subject: [PATCH v2] Add --align parameter to pvcreate
In-Reply-To: <49872A4C.6090908@redhat.com>
References: <49804A78.3020302@redhat.com>  <4982EAEC.9000209@redhat.com>
	<1233592128.5366.13.camel@localhost.localdomain>
	<49872A4C.6090908@redhat.com>
Message-ID: <1233617355.5366.45.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mon, 2009-02-02 at 18:15 +0100, Milan Broz wrote:
> Dave Wysochanski wrote:
> >>  # Miscellaneous global LVM2 settings
> >>  global {
> >> -    
> >> +
> >>      # The file creation mask for any files and directories created.
> >>      # Interpreted as octal if the first digit is zero.
> >>      umask = 077
> > 
> > Uintended whitespace changes?
> 
> well, intended (whitespace cleaning),  but not necessary for patch:-)
> 

ok.

> 
> >> -unsigned long pe_align(struct physical_volume *pv)
> >> +unsigned long pe_align(struct physical_volume *pv, unsigned long force_pe_align)
> > 
> > 
> > Inconsistent naming?  You have 'req_pe_align', 'align', and
> > 'force_pe_align'.
> 
> ...and physicalvolumealign_ARG, and pv_alignment in lvm.conf
> 
> I know, but if it is consistent in one place, it breaks somewhere else.
> The idea was
> 	align is read from --align CLI parameter in pvcreate.c
> 
> (and is --align for commandline ok here?)
> 

Actually, now that you mention it and I look at it more, for consistency
with other 'size' parameters, we might want "--alignsize".  If it were
me I'd err on the side of length rather than ambiguity.  Then again,
"--physicalvolumealignsize" might be over the top.  We do have
--physicalextentsize in vgcreate, and this is a related param.
--physicalextentalignsize?


> Others were just prefixes (req_/force_)
> 
> So if we have some name consistency rules, I'll rename it according it,
> I just need to know these rules:-)
> 
> See for example this 
> 	pp->pe_start = pv_pe_start(existing_pv);
> 	pp->extent_size = pv_pe_size(existing_pv);
> 	pp->extent_count = pv_pe_count(existing_pv);
> 
> so pe_size or extent_size? align or pe_align or ... ?
> 

I was mainly reacting to your naming in that same file which seemed
inconsistent.  I thought 'req_pe_align' was fine for those cases.  If
the same thing is being passed around, there's no change in meaning, and
there's no namespace conflict, code normally keeps the same naming.
There's certainly inconsistencies in the code.  For user-visible
changes, they have their own (similar) namespace but we should try to be
consistent between things like cmdline options and conf file options.
Where we can't, a small explanation (like your "pvs -o +pe_start"
sentence to query the value) helps.


> >> +.BR \-\-align " size"
> >> +Force align start of the payload to specified boundary (to align
> >> +with underlying RAID device stripe or chunk).
> >> +Note that you should use properly sized physical extent later
> >> +in vgcreate to correctly align all Logical Volumes start too.
> >> +.TP
> > 
> > Might be worth adding a sentence or two of how to query / derive this
> > value.  I would guess someone will use this value, then want to verify
> > it is set correctly.  I know we don't store it so we can't add it to the
> > reporting code as a field but we can point out the use of pe_start and
> > pe_size.
> 
> Yes, so I'll add
> 
> "To print the current data payload offset for the Physical Volume use
> pvs -o +pe_start command.  The reported value is always multiple
> of requested alignment value".
> 
> Any other suggestions?
> 

Did you forgot to update man/lvm.conf.5

Also looks like you need another check in there for a minimum size
(cannot be less than metadatasize):
tools/lvm pvcreate --align 1 /dev/loop0
  Physical volume "/dev/loop0" successfully created
root at dwysocha-rhel5-laptop:newlvm2git> tools/lvm pvs -opv_name,vg_name,pe_start,mda_size,pv_size
  PV         VG   1st PE  PMdaSize  PSize  
  /dev/loop0        1.00K   128.00K 101.00M
  /dev/loop1      192.00K   188.00K 101.00M
  /dev/loop2      192.00K   188.00K 101.00M
  /dev/loop3      192.00K   188.00K 101.00M



