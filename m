From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 05 May 2010 11:31:51 -0400
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <87pr1a3i4w.fsf@twilight.int.mornfall.net.>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>	<4BD88E71.3040902@redhat.com>
	<87pr1a3i4w.fsf@twilight.int.mornfall.net.>
Message-ID: <4BE18F67.9080005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Petr,

On 05/05/10 03:46, Petr Rockai wrote:
> Takahiro Yasui <tyasui@redhat.com> writes:
>> It is very grad that the patch to fix this issue was being developed.
>> I have not thoroughly read it, but I found one issue. It doesn't work
>> for a "mirrored" log, while it looks good for a "core" or "disk" log.
> [snip]
> 
> this is not really an issue with the new code per se. What needs to be
> done is that lvconvert --repair itself needs to be changed to handle
> mirrored logs correctly.
> 
> What needs to be done is to call the repair recursively on the log
> device if it is a mirror.

I understand. I will wait and test your updated patch.

>> The current code calls lv_check_transient() at the beginning of
>> _lvconvert_mirrors_repair() but I think that lv_check_transient()
>> needs to be called in functions which repairs a mirror log,
>> such as _lv_update_log_type(), too.
> (see above)
> 
>> Also this patch works well not only for a transient error but
>> also a medium error, therefore, function names with '_transient'
>> could be '_status' or '_status_string'. (e.g. lv_check_status())
> I chose transient not because of "transient error", but because of the
> relation to the transient, in-kernel, status of the device -- as opposed
> to persistent, i.e. in metadata. Maybe something with "active" or
> "activation" in it would be better though...

I see your point. I just thought 'a medium error' is persistent
and commented, but I will follow your decision.

Thanks,
Taka


