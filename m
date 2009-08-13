From: Petr Rockai <prockai@redhat.com>
Date: Thu, 13 Aug 2009 17:00:07 +0200
Subject: [PATCH] DRAFT! write lock priority
In-Reply-To: <20090812225043.GR7033@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Wed, 12 Aug 2009 23:50:43 +0100")
References: <87skfxtr89.fsf@twilight.int.mornfall.net.>
	<20090812223551.GQ7033@agk-dp.fab.redhat.com>
	<20090812225043.GR7033@agk-dp.fab.redhat.com>
Message-ID: <874osbu5c8.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> Updated version of the second patch.
> Handing back over to you for further cleanup, review & testing.
Another iteration of second patch attached. This should mostly address the
raised concerns, and also adds documentation to example.conf. It still uses the
aux_ prefix, see also my other mail.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: locking2.diff
Type: text/x-diff
Size: 4349 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090813/7775056a/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

PS: Sorry for the file_aux vs LOCK_EX screwup on my part, good you noticed and
fixed that part. (At least we know why we are reviewing patches...)
