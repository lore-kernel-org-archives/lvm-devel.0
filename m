From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 13 Oct 2017 14:04:29 +0200
Subject: [RFC] lvmetad_is_disabled: check config before connecting to socket
In-Reply-To: <c0d24b57-5f33-4b35-39ea-596db5028c37@proxmox.com>
References: <20171013090842.28186-1-t.lamprecht@proxmox.com>
	<0db6e3d2-4255-297f-46e0-72e729ee5da7@redhat.com>
	<c0d24b57-5f33-4b35-39ea-596db5028c37@proxmox.com>
Message-ID: <783e44c0-6836-ed8d-ee03-91f56ca0dce0@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.10.2017 v 13:23 Thomas Lamprecht napsal(a):
> On 10/13/2017 12:06 PM, Zdenek Kabelac wrote:
>> Dne 13.10.2017 v 11:08 Thomas Lamprecht napsal(a):
>>> Else, lvmetad always gets started due to systemds socket auto
>>> activation when executing, for example:
>>>  ? # pvscan --cache
>>> as pvscan uses lvmetad_is_disabled to check if metad is disabled
>>> before connecting. This is OK for systems where systemd is not used
>>> but for others, the systemd 'auto activation on socket connect'
>>> feature causes the start of lvm2-lvmetad.service which is not desired
>>> when disabled in the config.
>>>
>>> ref: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=826570
>>> Signed-off-by: Thomas Lamprecht <t.lamprecht@proxmox.com>
>>> ---
>>>
>>> An alternative approach would be to just guard the lvmetad_is_disabled
>>> call in tools/pvscan.c : 412 with the config check - and thus address
>>> the FIXME mentioned there.
>>> Would be maybe the less intrusive version?
>>>
>>
>>
>> Hi
>>
>> The reason why is checked the presence for active service when lvmetad is disable is - we have to print warning that? lvmetad is there, but command is not going to use it/update it....
> 
> Why not just do the initial fix over a lvmetad.pid file?
> Simpler and avoids auto activation.
> 

There is clear race - your command would be 'checking' for pid for lvmetad 
which is just being re/started.  The only valid way for checking of presence 
of running lvmetad in the system is a presence of socket. All other solution 
have various troubles.

> I must then mask also the socket as it has a require on the server.
> As lvm2-monitor.service requires both, lvm2-lvmetad.service lvm2-lvmetad.socket

Well yes - if you do not want to use 'lvmetad' in your system - you need to 
use different set of service dependencies.

The main point is - user might be switching of usage of lvmetad with any 
command - i.e. just pass different setting with --config command option.

> 
> This then leads to a (after some time) periodic log spamming:
> 
>> Oct 10 08:17:23 dev5 systemd[1]: lvm2-monitor.service: Cannot add dependency job, ignoring: Unit lvm2-lvmetad.socket is masked.
>> Oct 10 08:17:23 dev5 systemd[1]: lvm2-lvmetad.socket: Cannot add dependency job, ignoring: Unit lvm2-lvmetad.socket is masked.
> 
> So not ideal for us, our and Debian's user.

IMHO this rather means the specification of the service should likely use 
different sort of dependence on a socket so it would not generate this log 
message.

Regards

Zdenek


