From: Milan Broz <mbroz@redhat.com>
Date: Thu, 03 Dec 2009 19:06:20 +0100
Subject: [PATCH] Remove newly created log volume if initial deactivation fails.
In-Reply-To: <1259862577.2283.7.camel@f10-node1>
References: <1259847079-23268-1-git-send-email-mbroz@redhat.com>
	<1259862577.2283.7.camel@f10-node1>
Message-ID: <4B17FE1C.2010407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/03/2009 06:49 PM, Dave Wysochanski wrote:
> On Thu, 2009-12-03 at 14:31 +0100, Milan Broz wrote:
>> If there is problem deactivate LV and
>> _init_mirror_log is called with remove_on_failure = 1,
>> remove the newly created log LV from metadata.
>>
>> (This can happen if there is active device with the same name
>> but different UUID.)
>>
>> Signed-off-by: Milan Broz <mbroz@redhat.com>
>> ---
>>  lib/metadata/mirror.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
>> index c331e0e..4c24058 100644
>> --- a/lib/metadata/mirror.c
>> +++ b/lib/metadata/mirror.c
>> @@ -256,7 +256,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
>>  	/* If the LV is active, deactivate it first. */
>>  	if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
>>  		if (!deactivate_lv(cmd, log_lv))
>> -			return_0;
>> +			goto revert_new_lv;
>>  		was_active = 1;
>>  	}
>>  
> 
> This doesn't look right based on my read of the function.
> First, if we goto revert_new_lv, we do all this recovery which is based
> on things that have not happened.  Also, later in the function we have
> this:

this is another case - the log LV was not active before but after
creation its deactivation failed. Read the fuction one level up
- _set_up_mirror_log

	if (!(log_lv = _create_mirror_log(lv, ah, alloc,
					  (const char *) lv_name, suffix))) {
		log_error("Failed to create mirror log.");
		return NULL;
	}

	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
		log_error("Failed to initialise mirror log.");

>>> we fail here, returning NULL but with metadata containing LV
create a few lines above.
		return NULL;
	}

	return log_lv;

I am fixing the path that completely unrelated device conflicts with
internally created device - so yes, manual intervention is needed too
but not to fix metadata but only remove that conflicting device.

> 	if (!deactivate_lv(cmd, log_lv)) {
> 		log_error("Aborting. Failed to deactivate mirror log. "
> 			  "Manual intervention required.");
> 		return 0;
> 	}

First, this is not patch to fix tests run, but part of my attempts to reproduce
bug 538571.

But this patch just tries to not leave metadata with _mlog device present, partially
abusing this error path. I think that run backup_vg() and some related operations
on LV which is going to be removed is maybe redundant here, but should not be problem.

Note, that this code path run _only_ if log_lv was previously created in the function
which calls this - so we can safely remove it (remove_on_failure is set).

> Do we just need a log_error() in your place above or is the recovery wrong later?

Code should remove the newly created log_lv if initialisation fails.

Milan


