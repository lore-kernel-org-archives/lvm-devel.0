From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 15 Oct 2010 15:15:50 +0100
Subject: [PATCH] automatic snapshot extension with dmeventd (BZ 427298)
In-Reply-To: <4CB84F49.9020602@redhat.com>
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
	<87r5g4lejw.fsf@twilight.int.mornfall.net.>
	<4CB6D2BC.9060404@redhat.com>
	<87aamffz2u.fsf@twilight.int.mornfall.net.>
	<4CB84F49.9020602@redhat.com>
Message-ID: <20101015141550.GH32395@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 15, 2010 at 02:55:37PM +0200, Zdenek Kabelac wrote:
> What I see as a problem for the future is how to resolve settings per each
> snapshot as current  'global' version - one setting for all snapshots is IMHO
> quite limiting.
 
When we discussed this I suggested storing the information directly against each LV
just as we do for other properties.  So you'd set it with lvcreate/lvchange or
inherit setting from vgcreate/vgchange or use default from lvm.conf or fallback
to builtin default.

That builds upon this patch, which is the first step.

Alasdair


