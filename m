From: Gerrard Geldenhuis <Gerrard.Geldenhuis@datacash.com>
Date: Thu, 20 Mar 2008 14:13:24 -0000
Subject: Posting a patch
In-Reply-To: <47E26A68.1040202@redhat.com>
References: <A78DB34D00374344A0AB65B6523C05DC02CDD316@marsden.win.datacash.com>
	<47E26A68.1040202@redhat.com>
Message-ID: <A78DB34D00374344A0AB65B6523C05DC02CDD32B@marsden.win.datacash.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks Bryn,

Here goes nothing...

I have attached a small patch for the lvm.8 man page to detail valid
characters and names. The man pages for pvcreate and lvcreate refer you
to lvm.8 for common options and I thougt it best to include naming
details in lvm.8 rather than duplicating information in each man page. I
have been sparse with making characters/keywords bold.

Regards

> -----Original Message-----
> From: lvm-devel-bounces at redhat.com
[mailto:lvm-devel-bounces at redhat.com]
> On Behalf Of Bryn M. Reeves
> Sent: 20 March 2008 13:45
> To: LVM2 development
> Subject: Re: [lvm-devel] Posting a patch
> 
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Gerrard Geldenhuis wrote:
> > I have written a small patch for the man page lvm.8 that I want to
> > submit. However I am unsure whether I should be creating a diff with
cvs
> > or diff and then if I use either what type of diff needs to be
> > submitted.
> 
> Hi Gerrard,
> 
> You can generate the patch either way - whichever you prefer. Either
one
> should be generated in unified diff format (-u). When I am taking
> patches from CVS I normally do:
> 
> cd ~/cvs/LVM2
> cvs diff -up 2>/dev/null > the.patch
> 
> The "-p" causes the diff to include the declaration for the function
> being changed - very handy for patches to .c files but probably not
> necessary for a man page patch.
> 
> Otherwise, I'd do something like:
> 
> cd LVM2/
> diff -Nurp man/lvm.8.orig man/lvm.8 > the.patch
> 
> Again, the -Nrp options probably aren't needed for a man page patch
but
> that's what I use for generating most of my patches.
> 
> Regards,
> Bryn.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm.8.diff-2007-03-20
Type: application/octet-stream
Size: 899 bytes
Desc: lvm.8.diff-2007-03-20
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080320/20085c98/attachment.obj>
