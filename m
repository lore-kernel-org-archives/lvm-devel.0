From: Petr Rockai <prockai@redhat.com>
Date: Tue, 23 Mar 2010 19:32:56 +0100
Subject: [PATCH] Allow incomplete mirror repairs in lvconvert --repair.
In-Reply-To: <87hbpi178m.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Mon, 15 Feb 2010 23:09:29 +0100")
References: <87hbpi178m.fsf@twilight.int.mornfall.net.>
Message-ID: <87sk7q51nr.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

re-sending the patch against current CVS, and with a minor bug fixed.

Petr Rockai <prockai@redhat.com> writes:
> the attached patch should address RHBZ 560105 and 560111. This changes
> lvconvert --repair as follows:
>
> - downconvert (like before)
> - try to replace everything (like before)
> - if the second step fails, try to reduce number of mirror images (one
>   at a time) until only 2 remain
> - if this still fails and we used to have a disk log, try 2-way + corelog
>
> This should basically give you an LV that is closest to the original
> mirror, in the space constraints of free PV areas.
>
> Please note that this patch also changes the failure/success returns of
> (manual) lvconvert --repair. As far as the initial downconversion
> succeeds -- i.e. the resulting LV is not partial, we report success.
>
> Failures to replace (part of) the failed devices are now reported as
> warnings.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-partial2.diff
Type: text/x-diff
Size: 5688 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100323/ab994915/attachment.bin>
