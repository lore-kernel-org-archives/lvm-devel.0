From: Milan Broz <mbroz@redhat.com>
Date: Thu, 03 Jun 2010 11:51:39 +0200
Subject: [PATCH] fix some issues in clvmd initscript
In-Reply-To: <4C07543C.5040908@redhat.com>
References: <4BFD1B92.9080403@redhat.com> <4C07543C.5040908@redhat.com>
Message-ID: <4C077B2B.5030206@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/03/2010 09:05 AM, Fabio M. Di Nitto wrote:
> On 5/26/2010 3:01 PM, Milan Broz wrote:
>> - if daemon is already running, do nothing (and not reactivate VGs)
>>
>> - always explicitly return exit code in reload()
>>
>> - fix restart() so it really tries full start & stop and returns exit code
>>   if clvmd -S fails and also touch lockfile afterwards
>>
>> --- clvmd.old	2010-05-26 14:21:15.000000000 +0200
>> +++ clvmd	2010-05-26 14:55:17.671245376 +0200
>> @@ -63,11 +63,12 @@ rh_status_q() {
>>  
>>  start()
>>  {
>> -	if ! rh_status_q; then
>> -		echo -n "Starting $DAEMON: "
>> -		daemon $DAEMON $CLVMDOPTS || return $?
>> -		echo
>> -	fi
>> +
>> +	rh_status_q && return 0
>> +
>> +	echo -n "Starting $DAEMON: "
>> +	daemon $DAEMON $CLVMDOPTS || return $?
>> +	echo
> 
> careful with this change as it modifies the behavior compared to the old
> init script.

So you want reactivate LVs even if clvmd is already running?
This is wrong IMHO.

Milan


