From: Milan Broz <mbroz@redhat.com>
Date: Fri, 20 Nov 2009 23:48:16 +0100
Subject: [PATCH] Un-export vg_read_internal.
In-Reply-To: <4B0535F0.4020301@redhat.com>
References: <87eiohq6et.fsf@twilight.int.mornfall.net.>
	<4B0535F0.4020301@redhat.com>
Message-ID: <4B071CB0.7040904@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/19/2009 01:11 PM, Milan Broz wrote:
> On 11/02/2009 04:43 PM, Petr Rockai wrote:
>> this was waiting a fairly long time for a round tuit, but here it is. This
>> should properly banish vg_read_internal into confinement in metadata.c. Should
>> be fairly obvious, I am just being paranoid here. (I made sure clvmd still
>> compiles this time, too.)
> 
>> @@ -780,9 +780,9 @@ void lvm_do_backup(const char *vgname)
>>  
>> 	pthread_mutex_lock(&lvm_lock);
>>  
>> -	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, &consistent);
>> +	vg = vg_read(cmd, vgname, NULL /*vgid*/, 0 /*flags*/);

post-mortem NACK

we cannot take lock inside vg_read here. it kills clvmd.

Milan


