From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 14 Mar 2013 16:39:11 +0100
Subject: [PATCH 4/5] lvm2app: Move core lv re-size code (v2)
In-Reply-To: <5141ECE3.6030401@redhat.com>
References: <1363212806-16025-1-git-send-email-tasleson@redhat.com>
	<1363212806-16025-4-git-send-email-tasleson@redhat.com>
	<5141DAEB.8080902@redhat.com> <5141E8F9.9020904@redhat.com>
	<5141E954.5040103@redhat.com> <5141ECE3.6030401@redhat.com>
Message-ID: <5141EF1F.7040003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.3.2013 16:29, Tony Asleson napsal(a):
> On 03/14/2013 10:14 AM, Zdenek Kabelac wrote:
>> Dne 14.3.2013 16:12, Tony Asleson napsal(a):
>>> On 03/14/2013 09:12 AM, Zdenek Kabelac wrote:
>>>> Dne 13.3.2013 23:13, Tony Asleson napsal(a):
>>>>> Moved to allow use from command line and for library use.
>>>>>
>>>>> Signed-off-by: Tony Asleson <tasleson@redhat.com>
>>>>> ---
>>>>>     lib/metadata/lv_manip.c          | 734
>>>>> +++++++++++++++++++++++++++++++++++++
>>>>>     lib/metadata/metadata-exported.h |  46 +++
>>>>>     tools/lvresize.c                 | 771
>>>>> ---------------------------------------
>>>>>     3 files changed, 780 insertions(+), 771 deletions(-)
>>>>>
>>>>> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
>>>>> index ad8160e..5baa9b3 100644
>>>>> --- a/lib/metadata/lv_manip.c
>>>>> +++ b/lib/metadata/lv_manip.c
>>>>> +    }
>>>>> +
>>>>> +    *stripesize = 0;
>>>>> +    return 0;
>>>>> +}
>>>>> +
>>>>> +int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
>>>>> +             struct lvresize_params *lp, struct dm_list *pvh)
>>>>> +{
>>>>
>>>> Non-internal -> remove '_' ->  ???_lvresize
>>>>
>>>> we should probably introduce some tool prefix to make it recognizable
>
> What should I use as a prefix for an internal use, non file local static
> function?
>

I guess - for now  'lv_resize()' will do its jobs.

Zdenek


