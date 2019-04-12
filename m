From: Gang He <ghe@suse.com>
Date: Thu, 11 Apr 2019 21:31:20 -0600
Subject: lvm snapshot creation ends with the error message
In-Reply-To: <436c0cec-21c1-593e-8095-c4fe1d5cff71@redhat.com>
References: <5CAC7071020000F90005E796@prv1-mh.provo.novell.com>
	<6fdd4655-4d3a-f12f-aa57-b97b752e437c@redhat.com>
	<5CAEFF6D020000F90005EF6C@prv1-mh.provo.novell.com>
	<436c0cec-21c1-593e-8095-c4fe1d5cff71@redhat.com>
Message-ID: <5CB00688020000F90005F430@prv1-mh.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

>>> On 4/11/2019 at  7:23 pm, in message
<436c0cec-21c1-593e-8095-c4fe1d5cff71@redhat.com>, Zdenek Kabelac
<zkabelac@redhat.com> wrote:
> Dne 11. 04. 19 v 10:48 Gang He napsal(a):
>> Hi Zdenek,
>> 
>> The LVM2 version is as below,
>>    rpm -V lvm2-2.02.120-78.16.1.x86_64
>> The other information is attached, see lvm.txt.
>> My question is, how do we disable this intermediate error message printing?
> 
> 
> Hi
> 
> Why is anyone using lvm2 version 2.02.120 ?
SLE12sp3 still uses this lvm2 version, we can not upgrade it directly.

> 
> Are you able to reproduce the error with more recent version of lvm2.
> (As there has been quite a long list of bug fixed).
I can not reproduce this bug in local with v2.02.120.
It looks only the user's environment can meet this error message, this user is using a backup product via lvm2 snapshot feature.
Do you have any suggestion for this situation? e.g. 
how to disable this intermediate error message printing?
or, the possible reasons? then we can tell the customer to avoid this retry loop.

Thanks
Gang

> 
> Regards
> 
> 
> Zdenek



