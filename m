From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Wed, 30 Jun 2010 17:20:36 -0400
Subject: [RFC][PATCH] lvm2: limit accesses to broken devices (v2)
In-Reply-To: <8739w4lly6.fsf@twilight.int.mornfall.net.>
References: <5C30BE7ED8B03E448B2E104602D4848A59228864BC@USINDEVS02.corp.hds.com>,
	<8739w4lly6.fsf@twilight.int.mornfall.net.>
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228864C9@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Petr,

Thank you for reviewing the patch.

On 06/30/10 08:54, Petr Rockai wrote:
> Takahiro Yasui <takahiro.yasui@hds.com> writes:
>>  int dev_read(struct device *dev, uint64_t offset, size_t len, void *buffer)
>>  {
>>  	struct device_area where;
>> +	int ret;
>>  
>>  	if (!dev->open_count)
>>  		return_0;
>>  
>> +	if (!_dev_is_valid(dev))
>> +		return 0;
> Maybe return_0 here?

As far as I understand, return_0 is for debugging of unexpected errors.
This is not a logical error, so I didn't used "return_0" here.

>> @@ -662,17 +684,25 @@ int dev_append(struct device *dev, size_
>>  int dev_write(struct device *dev, uint64_t offset, size_t len, void *buffer)
>>  {
>>  	struct device_area where;
>> +	int ret;
>>  
>>  	if (!dev->open_count)
>>  		return_0;
>>  
>> +	if (!_dev_is_valid(dev))
>> +		return 0;
> (and here)

Same here.

>>  	dev->flags |= DEV_ACCESSED_W;
>>  
>> -	return _aligned_io(&where, buffer, 1);
>> +	ret = _aligned_io(&where, buffer, 1);
>> +	if (!ret)
>> +		_dev_inc_error_count(dev);
>> +
>> +	return ret;
> Hmm. Should write errors count towards this? What happens if the device
> just rejects writes -- could this break code by yanking the device
> completely? This means, IIUIC, that any subsequent rescan that may
> happen won't see the device even if the failure was due to failing
> writes and the device reads just fine.

I haven't seen the case that a device accepts read I/Os but rejects
write I/Os, but the opposite case could happen. I heard that some
devices re-allocated a bad sector when a write I/O came to devices.

However, as far as I understand, writes aren't issued to devices
when reads don't succeed. Writes are for updating lvm header or
metadata and I think that lvm commands consider those missing
devices as failed devices and no writes are issued to those devices.

With the reason above, I think that the current implementation is
reasonable.

> I guess this is a corner case, but I would be surprised if there were
> any significant use-cases for tracking write errors for this purpose:
> the primary reason for the code is repeated read errors, I believe?

Yes, the primary reason for this code is to suppress repeated read
errors, but it is better if this patch can prevents repeated write
I/Os, as well.

> Of course, not writing to the device that cannot be read is certainly
> prudent -- do not remove the check near the top of dev_write if you
> decide to not track write errors as per above.
> 
> Other than this, I think the patch looks OK.

Again, thank you for reviewing this patch, Petr.
I appreciate your comments.

Thanks,
Taka


