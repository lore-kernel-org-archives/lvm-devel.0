From: Amir G. <amir73il@users.sourceforge.net>
Date: Sat, 11 Jun 2011 08:41:38 +0300
Subject: LVM vs. Ext4 snapshots (was: [PATCH v1 00/30] Ext4 snapshots)
In-Reply-To: <20110610101142.GA10144@ubuntu>
References: <BANLkTimyBGfg4+ovGsiGqpCz345qVmU_7A@mail.gmail.com>
	<BANLkTik20iYN4c9faKD9dzerehazWTwTFw@mail.gmail.com>
	<BANLkTikKRuPu_NX49vr0w-XeN0ZnWo+9vg@mail.gmail.com>
	<alpine.LFD.2.00.1106101101020.4502@dhcp-27-109.brq.redhat.com>
	<20110610101142.GA10144@ubuntu>
Message-ID: <BANLkTi=0N7QXRvFgjHUJXBi0x=668ahXXA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jun 10, 2011 at 1:11 PM, Joe Thornber <thornber@redhat.com> wrote:
> On Fri, Jun 10, 2011 at 11:01:41AM +0200, Lukas Czerner wrote:
>> On Fri, 10 Jun 2011, Amir G. wrote:
>>
>> > CC'ing lvm-devel and fsdevel
>> >
>> >
>> > On Wed, Jun 8, 2011 at 9:26 PM, Amir G. <amir73il@users.sourceforge.net> wrote:
>> > For the sake of letting everyone understand the differences and trade
>> > offs between
>> > LVM and ext4 snapshots, so ext4 snapshots can get a fair trial, I need
>> > to ask you
>> > some questions about the implementation, which I could not figure out by myself
>> > from reading the documents.
>
> First up let me say that I'm not intending to support writeable
> _external_ origins with multisnap. ?This will come as a suprise to
> many people, but I don't think we can resolve the dual requirements to
> efficiently update many, many snapshots when a write occurs _and_ make
> those snapshots quick to delete (when you're encouraging people to
> take lots of snapshots performance of delete becomes a real issue).
>

If I understand this article correctly:
http://people.redhat.com/mpatocka/papers/shared-snapshots.pdf
It says that _external_ origin write updates can be efficient to readonly
(or not written) snapshots.

Could you not support readonly snapshots of an _external_ origin?

You could even support writable snapshots, that will degrade write
performance to origin temporarily.
It can be useful, if one wants to "try-out" mounting a temporary
writable snapshot, when the origin is not even mounted.
After the "try-out", the temporary snapshot can be deleted
and origin write performance would go back to normal.

Is that correct?

Amir.


