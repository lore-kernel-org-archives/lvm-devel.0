From: Daniel Mierswa <impulze@impulze.org>
Date: Wed, 30 Sep 2009 03:00:02 +0200
Subject: [PATCH 2/3] differentiate between S.I. and binary units in output
In-Reply-To: <20090928164410.GH5351@agk-dp.fab.redhat.com>
References: <1253979227-28051-1-git-send-email-impulze@impulze.org>
	<1253979227-28051-2-git-send-email-impulze@impulze.org>
	<20090928164410.GH5351@agk-dp.fab.redhat.com>
Message-ID: <4AC2AD92.4040603@impulze.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 28.09.2009 18:44, Alasdair G Kergon wrote:
> So please would you:
>    1) Make this change conditional on a runtime check of
> cmd->si_unit_consistency;
Attached, hope it's bug free, somehow all things went crazy and I got 
very busy this week but don't couldn't wait any longer to get this merged.

>    2) Remove the 500-byte sector offering.
Figured, you already did.

> The new-style output can be the default from 2.02.54 onwards - Fedora
> 13, RHEL6 etc.
We still need to tweak the documentation at places, which I can do as 
soon as the patches are for the actual code handling are applied.

> People who find problems with their scripts after an upgrade can easily
> reinstate the old inconsistent output by using an lvm.conf setting.
Yep, win win. Good solution in the end anyway although it requires the 
LVM2 development team to keep "old" code around, which I prefer not to 
if I can avoid it. ;)

-- 
Mierswa, Daniel

If you still don't like it, that's ok: that's why I'm boss. I simply 
know better than you do.
                --- Linus Torvalds, comp.os.linux.advocacy, 1996/07/22
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: 0001-differentiate-between-S.I.-and-binary-units-in-outpu.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090930/394a27a0/attachment.ksh>
