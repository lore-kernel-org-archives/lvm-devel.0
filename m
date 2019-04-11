From: Gang He <ghe@suse.com>
Date: Thu, 11 Apr 2019 02:48:45 -0600
Subject: lvm snapshot creation ends with the error message
In-Reply-To: <6fdd4655-4d3a-f12f-aa57-b97b752e437c@redhat.com>
References: <5CAC7071020000F90005E796@prv1-mh.provo.novell.com>
	<6fdd4655-4d3a-f12f-aa57-b97b752e437c@redhat.com>
Message-ID: <5CAEFF6D020000F90005EF6C@prv1-mh.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

The LVM2 version is as below,
  rpm -V lvm2-2.02.120-78.16.1.x86_64
The other information is attached, see lvm.txt.
My question is, how do we disable this intermediate error message printing? 

Thanks
Gang

>>> On 2019/4/9 at 22:53, in message
<6fdd4655-4d3a-f12f-aa57-b97b752e437c@redhat.com>, Zdenek Kabelac
<zkabelac@redhat.com> wrote:
> Dne 09. 04. 19 v 12:14 Gang He napsal(a):
>> Hello Guys,
>> 
>> Our user complained a confused error message when create a LV snapshot 
> successfully.
>> e.g.
>> lvcreate --snapshot "/dev/$vgroup/$volume" --name "$snapvol" -l '80%FREE'
>> returns the following:
>> Taking snapshot mongo_db-snap
>>    device-mapper: remove ioctl on (254:2) failed: Device or resource busy  <<== 
> here, why we need to print this error message? since we can retry a few time 
> before failure
>>    Logical volume "mongo_db-snap" created.
>> 
>> The related code is in libdm-iface.c file under libdm/ioctl.
> 
> Hi
> 
> The error should NOT happen - if you can observe this report - somewhere is 
> something going out-of-sync.
> 
> So please - post the version and  -vvvv log of this case.
> 
> It does look like somewhere is missing synchronization wait.
> 
> 
> Zdenek

-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvm.txt
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190411/08c795a4/attachment.txt>
