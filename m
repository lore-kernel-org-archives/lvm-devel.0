From: Petr Rockai <prockai@redhat.com>
Date: Thu, 25 Nov 2010 14:53:12 +0100
Subject: [PATCH] Refactor handling of percent values (towards BZ 654441)
In-Reply-To: <87eia9o9b6.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Thu, 25 Nov 2010 13:51:41 +0100")
References: <87eia9o9b6.fsf@twilight.int.mornfall.net.>
Message-ID: <87aakxo6gn.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again,

Petr Rockai <prockai@redhat.com> writes:
> the attached patch changes over the percent handling in the code: it
> folds all percent values into a single fixed-point value, instead of a
> floating point and an enum. This simplifies existing code (no need to
> pass around extra variable/parameter), while also making it possible to
> expose the percent attributes through the lvm2app API as a single
> integral value (this is BZ 654441).

and now an amended patch, taking Alasdair's IRC feedback into account. I
have moved the implementation aside to a separate unit, and added a
comment explaining how the percent_t type works.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: percent-refactor.diff
Type: text/x-diff
Size: 36005 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101125/d5653007/attachment.bin>
-------------- next part --------------

Yours,
   Petr.
