From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 20 Aug 2010 15:09:05 +0200
Subject: patch1/4: lvm manpages
In-Reply-To: <1282262317.3337.94.camel@fermat.scientia.net>
References: <1282262317.3337.94.camel@fermat.scientia.net>
Message-ID: <4C6E7E71.6020601@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.8.2010 01:58, Christoph Anton Mitterer napsal(a):
> Hi.
> 
> Attached would be several patches, that (IMHO) improve the lvm(8) manpage:
> 
> 
> 
> 1) lvm.8.empty_LV.patch
> It seems that the current "Where a list of VGs is required but is left empty, a
> list  of  all VGs will be substituted." is also true for LVs (checked it with
> lvdisplay, which seems to lists all LVs).
> If this is true, add the patch, to reflect this in the documentation
> 

lvdisplay - with empty list will substitutes with all VGs - thus effectively
display all LVs from all VGs - but it doesn't mean there is some substitution
for LVs. It's the effect of command that it displays all LVs from given VG.
Lots of commands scans for all LVs in given VGs  (i.e. vgchange).

So this patch is rejected.

Zdenek


