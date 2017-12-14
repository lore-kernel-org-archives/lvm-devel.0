From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 14 Dec 2017 15:07:29 +0100
Subject: [PATCH] test: lvmetad_dump always timed out when using nc
In-Reply-To: <2863cb23-45f1-7eee-e446-9995bf78262f@suse.com>
References: <20171213111303.24775-1-zren@suse.com>
	<02180207-fc63-f9c2-64b0-82224eef1a3e@suse.com>
	<4b234d1c-be10-beba-642f-32bb5dc01ff4@redhat.com>
	<2863cb23-45f1-7eee-e446-9995bf78262f@suse.com>
Message-ID: <b831437a-598f-ff68-5e24-55ccd8dbaebe@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.12.2017 v 14:28 Eric Ren napsal(a):
> Hi,
> 
> On 12/14/2017 06:39 PM, Zdenek Kabelac wrote:
>> Dne 14.12.2017 v 11:27 Eric Ren napsal(a):
>>> Hi zkabelac,
>>>
>>> Hmm strange, tested on fedora, it has not this issue.
>>>
>>> ```
>>>
>>
>> Hi
>>
>> Yep - in fact I've? been a bit puzzled by your patch since I could not think 
>> why that should be needed.
> 
> Hah sorry, I will always verify the issue on fedora first when I report 
> problem in upstream :)
> 
>>
>> We will possibly need to put OpenSuse as a test machine somewhere.
> 
> Thanks, but it's not a very trivial task. openSUSE tumbleweed is a rolling 
> release, which
> is usually used for developing purpose, but it's not that easy to maintain 
> (upgrade). Besides,
> some raid testcases in upstream code can pass on fedora, but fail on openSUSE, 
> which seems
> caused by some raid kernel patches (not yet inspect carefully on those failures).
> 
> It's already very cool to have such kind upstream, appreciate!
> 
>>
>>
>> Can you provide full test trace where you get lock ?
>>
>>
>> 'make check_local T=selectsometest? VERBOSE=1 LVM_TEST_AUX_TRACE=1 &>/tmp/log'
> 
> 'make check_local' is skipped:
> ```
> tw1:~/lvm2/test # make check_local T=lvmetad-dump? VERBOSE=1 
> LVM_TEST_AUX_TRACE=1? &>/tmp/log1.txt
> ```
> 
> 'make check'? hangs up forever until CTR+c:
> ```
> tw1:~/lvm2/test # make check T=lvmetad-dump? VERBOSE=1 LVM_TEST_AUX_TRACE=1  
> &>/tmp/log2.txt
> ^C
> ```
> 
> The logs are attached.


While the trace shows nothing wrong - isn't this same issue as you had with 
dmeventd ?

Both services needs to be masked together with their sockets on testing 
machine for testing services (unless you build test package which then is able 
to run with installed binaries)

Although the socket for testing should be different from 'real one'.

but anyway - you need to provide trace from blocking run:

make check_lvmetad T=lvmetad-dump  VERBOSE=1 LVM_TEST_AUX_TRACE=1 &>/tmp/log.txt



Regards

Zdenek


