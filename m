From: Germano Percossi <germano.percossi@citrix.com>
Date: Mon, 31 Jul 2017 10:22:18 +0100
Subject: Batch/queue LVM operations
In-Reply-To: <d703293c-192c-c448-f2cb-cf1f5e374cbe@redhat.com>
References: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
	<fcfc34d4-eb7e-ce89-b83f-39d4fff56cbb@citrix.com>
	<d703293c-192c-c448-f2cb-cf1f5e374cbe@redhat.com>
Message-ID: <ac02fc91-130a-8407-153c-8b371c4b1327@citrix.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

OK, good to know.

It was in non-production code, anyway.

Thanks,
Germano

On 07/31/2017 10:19 AM, Zdenek Kabelac wrote:
> Dne 31.7.2017 v 11:01 Germano Percossi napsal(a):
>> Hi,
>>
>> Not sure if it an option for you but the Python bindings
>> allow you to instantiate a VG object that will hold the
>> lock and then issue all the commands you want before
>> flushing the metadata at the very end.
> 
> 
> Hi
> 
> Please avoid using these Python binding or lvm2app.
> Those 2 things are not being developed and are mostly left
> there purely for backward compatibility reasons. So no new APP should
> ever use it - and old APPs will simple face lots of troubles....
> 
> It's in general unsupportable to lvm2 this way (API was badly designed and
> we even figured later we really can't support it ).
> And it's even less usable to workaround locking across bunch of commands...
> 
> What is now being tested is dBus integration - but this has still long
> way to go.  So whenever you can - please use  lvm2 commands with is
> documented
> and well tested API.
> 
> 
> Regards
> 
> Zdenek


