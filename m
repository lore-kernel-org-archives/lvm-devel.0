From: Petr Rockai <prockai@redhat.com>
Date: Thu, 07 Jan 2010 22:00:41 +0100
Subject: [PATCH] Relax exit codes for policy-driven lvconvert --repair.
In-Reply-To: <873a2h4rb2.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Thu, 07 Jan 2010 21:02:09 +0100")
References: <873a2h4rb2.fsf@twilight.int.mornfall.net.>
Message-ID: <87wrzt3a12.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again,

Petr Rockai <prockai@redhat.com> writes:
> due to the interpretation of "replace" policies as "replace if possible,
> downconvert otherwise", we should treat successful downconversion as a
> success in these cases, even if we were unable to replace the missing
> devices with new ones.
>
> The attached patch also makes the "nothing to repair" condition a
> non-error (with and without --use-policies... it's arguably not really
> an error). This would hopefully address RHBZ 552723, if it is indeed the
> case (as it seems) that the problem there is that the missing devices
> have already returned by the time that lvconvert --repair kicks in (and
> therefore it does not detect anything to repair).

an amended patch that also ensures that MISSING_PV removal is done even
if device replacement fails is attached, and an interdiff with only the
new changes.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-dont-skip-remove_missing_empty_pv.diff
Type: text/x-diff
Size: 1741 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100107/40fc3df7/attachment.bin>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-relax-failures-with-policy-2.diff
Type: text/x-diff
Size: 6577 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100107/40fc3df7/attachment-0001.bin>
