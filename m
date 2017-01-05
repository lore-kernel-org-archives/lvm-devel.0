From: NeilBrown <neilb@suse.com>
Date: Thu, 05 Jan 2017 14:44:20 +1100
Subject: [lvm2 PATCH] Remove special-case for md in 69-dm-lvm-metadata.rules
In-Reply-To: <e0225e4c-80fe-359e-462a-5829195ca5b6@redhat.com>
References: <87eg0jmrgz.fsf@notabene.neil.brown.name>
	<e0225e4c-80fe-359e-462a-5829195ca5b6@redhat.com>
Message-ID: <87wpeakw6j.fsf@notabene.neil.brown.name>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jan 04 2017, Peter Rajnoha wrote:

> On 01/04/2017 04:30 AM, NeilBrown wrote:
>> 
>> This special casing brings no value.  It appears to attempt to
>> determine if the array is active yet or not, and to skip
>> processing if the array has not yet been started.
>
> Hi Neil,
>
> those rules also have another use which is to not trigger further
> unnecessary actions if the device is already up and running, hence
> avoiding useless resource consumption if it brings no new information.
> Currently, this is applied only for running pvscan on top of newly
> activated MD device (that's why it's part of 69-dm-lvm-metad.rules
> at the moment).

I am having difficulty seeing why MD devices should be handled
differently from any others in this respect.  If you want to filter out
unhelpful event for MD, surely you should filter them out for all
devices??

I also wonder if there are really so many unhelpful events that there is
a genuine gain in filtering them out.

>
> So what we also need is to detect the very first CHANGE event
> that makes the device active and to make a difference between this
> first CHANGE event and further CHANGE events which are possibly
> part of the WATCH rule and any other possible CHANGE events which
> do not notify about the device switching from "not ready" to "ready"
> state (of course, counting with possible coldplug events).
>
>> However, if the array hasn't been started, then "blkid" will
>> not have been able to read a signature, so:
>>   ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"
>> will have caused all this code to be skipped.
>> 
>> Further, this code causes incorrect behaviour in at least one case.
>> It assumes that the first "add" event should be ignored, as it will be
>> followed by a "change" event which indicates the array coming on line.
>> This is consistent with how the kernel sends events, but not always
>> consistent with how this script sees event.
>> Specifically: if the initrd has "mdadm" support installed, but not
>> "lvm2" support, then the initial "add" and "change" events will
>> happen while the initrd is in charge and this file is not available.
>> Once the root filesystem is mountd, this file will be available
>> and "udevadm trigger --action=add" will be run.
>> So the first and only event seen by this script for an md device will be
>> "add", and it will incorrectly ignore it.
>> 
>
> Yes, you're right that in this case, it's not behaving correctly when
> the initrd doesn't have this rule while the root FS does.  To fix this
> issue for now, I suggest to separate those rule out of 69-dm-lvm-metad.rules
> and make it a part of MD rules so that rule is always available both in
> initrd and root fs when MD is used (while LVM doesn't need to be
> installed in initrd).
>
> This comes right on time because right at this very moment, I'm working
> on a design for a solution which covers this area - I'll surely pass you
> the design doc once it's more complete (should be in next few days) so
> you we can discuss this problem further. This will cover the *standard*
> notification about when the block device is ready which provides a
> standard way of letting others (rules or any uevent monitors) know when
> the switch from "not ready" to "ready" state happens exactly. This should
> save us lots of unnecessary work that is done at the moment - we don't
> need to fire scans and further inspection of the device for all the
> events all the time. This work also covers identification of spurious
> events coming as a result of the WATCH rule and minimization of its
> impact on uevent processing performance in userspace.

I'd certainly be very interested to read and comment on your design.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20170105/1e28b9b0/attachment.sig>
