From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 22 Dec 2010 11:16:40 +0100
Subject: [PATCH 07/23] Move lastfd handling into for()
In-Reply-To: <4D10DAC1.9050708@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<403be35b0f1d1d1da149e3d9a948a6416475287e.1292945707.git.zkabelac@redhat.com>
	<4D10DAC1.9050708@redhat.com>
Message-ID: <4D11D008.1010303@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 21.12.2010 17:50, Milan Broz napsal(a):
> On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:
> 
>> @@ -826,7 +826,8 @@ static void main_loop(int local_sock, int cmd_timeout)
>>  
>>  				if (thisfd->removeme) {
>>  					struct local_client *free_fd;
>> -					lastfd->next = thisfd->next;
>> +					if (lastfd)
>> +						lastfd->next = thisfd->next;
> 
> Isn't that replacing one bug with another?
> 
> If lastfd is NULL, it will crash.
> After your change it will quietly do something, apparently with wrong pointers.
> 
> If lastfd cannot be NULL, the check is not needed and is redundant.
> 
> I *think* that the first fd in select is local one, removing itself is nonsense,
> so lastfd should be always set. (lastfd is set in the for cycle)
> 
> Anyway I prefer to keep the code intact instead of hiding possible bug.
> 
> (Or rewrite it to something more readable. e.g. removeme flag
> seems to be used only in gulm code, which is dead and unsupported etc)
> 


The code is really a bit complicated to read in this case - so that's why I've
commented the patch that clvmd expert is needed.

Other way around in the patch could be - to simply skip first loop case
and assign the first value directly to  'lastfd' and start for() directly with
the next element. That would make code more obvious that the list always needs
to have at least 2 members.

Other question is - if we do not support gulm anymore - why do we keep
unmaintained and untested code ? :)

Zdenek


