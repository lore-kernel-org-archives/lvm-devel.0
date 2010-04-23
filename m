From: Josh Moyer <jmoyer@nodomain.net>
Date: Fri, 23 Apr 2010 16:01:43 -0400
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
Message-ID: <E8D3F161D3368B4CBED2E589B65B8F8F1386E21D06@MAILR002.mail.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



-----Original Message-----
From: Takahiro Yasui <tyasui@redhat.com>
Sent: April 23, 2010 12:47 PM
To: lvm-devel@redhat.com <lvm-devel@redhat.com>
Subject: Re: [lvm-devel] [BUG-REPORT] mirror legs in the same PV with --alloc anywhere


On 04/23/10 17:09, brem belguebli wrote:
> On Fri, 2010-04-23 at 14:54 -0400, Takahiro Yasui wrote:
>> On 04/23/10 12:01, brem belguebli wrote:
>>> I've read in the RHEL 5.5 technical datasheet that the shipped LVM
>>> version 2.02.56 was alraedy capable of mirrored log.
>>
>> As far as I see lvm2 code, I don't think lvm2 in RHEL5.5 has
>> mirrored log feature. I'm not sure which document you referred to.
>> Could you tell me the exact name of "RHEL 5.5 technical datasheet"?
>
> http://www.redhat.com/f/pdf/rhel/RHEL_5_5_TechOverview_wp_web.pdf
> page 4, LVM
>
> " LVM ??? the Logical Volume Management storage suite has been augmented
> to provide hot sparing
>  for mirror journals, enabling automatic replacement or removal of
> failed logging devices.
> "

Thanks for the information, but I am not sure if this sentence is
telling 'mirrored log.' What I can say is the lvm2-2.02.56-8 doesn't
have 'mirrored log' feature. I hope someone may give you a explanation...

Thanks,
Taka

--
lvm-devel mailing list
lvm-devel at redhat.com
https://www.redhat.com/mailman/listinfo/lvm-devel


