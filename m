From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 24 Jul 2013 00:41:56 +0200
Subject: master - lvm2app: lvm_vg_list_lvs filter hidden LVs
In-Reply-To: <51EEE05C.4080805@redhat.com>
References: <20130723190305.9850E60D4C@fedorahosted.org>
	<51EED929.6050006@redhat.com> <51EEE05C.4080805@redhat.com>
Message-ID: <51EF06B4.5030804@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 23.7.2013 21:58, Tony Asleson napsal(a):
> On 07/23/2013 02:27 PM, Zdenek Kabelac wrote:
>> Dne 23.7.2013 21:03, tasleson napsal(a):
>>> Gitweb:
>>> http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2b51476007aae91acfc121a7fd2ce04f3b08781
>>>
>>> Commit:        a2b51476007aae91acfc121a7fd2ce04f3b08781
>>> Parent:        31de670318c9794690601468def392cd7e4eb0fc
>>> Author:        Tony Asleson <tasleson@redhat.com>
>>> AuthorDate:    Tue Jul 23 14:57:53 2013 -0400
>>> Committer:     Tony Asleson <tasleson@redhat.com>
>>> CommitterDate: Tue Jul 23 14:01:20 2013 -0500
>>>
>>> lvm2app: lvm_vg_list_lvs filter hidden LVs
>>>
>>> The function lvm_vg_list_lvs was returning all logical
>>> volumes, including *_tmeta and *_tdata.  Added check
>>> to verify that LV is visible before including in list
>>> of returned logical volumes.
>>
>> I'm afraid you can't break API this way.
>> If there is a need for filtered list - you need to filter
>> list passed from this function - or add something like
>> lvm_vg_list_visible_lvs.
>
> What kind of modifications are users doing to the hidden meta-data/data
> components of a LV thin pool that they would reference each part
> individually?


i.e. you could convert  _tmeta into mirror.
And there are other hidden volumes which could be legally removed.

Zdenek




