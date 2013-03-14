From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 14 Mar 2013 16:14:28 +0100
Subject: [PATCH 4/5] lvm2app: Move core lv re-size code (v2)
In-Reply-To: <5141E8F9.9020904@redhat.com>
References: <1363212806-16025-1-git-send-email-tasleson@redhat.com>
	<1363212806-16025-4-git-send-email-tasleson@redhat.com>
	<5141DAEB.8080902@redhat.com> <5141E8F9.9020904@redhat.com>
Message-ID: <5141E954.5040103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.3.2013 16:12, Tony Asleson napsal(a):
> On 03/14/2013 09:12 AM, Zdenek Kabelac wrote:
>> Dne 13.3.2013 23:13, Tony Asleson napsal(a):
>>> Moved to allow use from command line and for library use.
>>>
>>> Signed-off-by: Tony Asleson <tasleson@redhat.com>
>>> ---
>>>    lib/metadata/lv_manip.c          | 734
>>> +++++++++++++++++++++++++++++++++++++
>>>    lib/metadata/metadata-exported.h |  46 +++
>>>    tools/lvresize.c                 | 771
>>> ---------------------------------------
>>>    3 files changed, 780 insertions(+), 771 deletions(-)
>>>
>>> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
>>> index ad8160e..5baa9b3 100644
>>> --- a/lib/metadata/lv_manip.c
>>> +++ b/lib/metadata/lv_manip.c
>>> +    }
>>> +
>>> +    *stripesize = 0;
>>> +    return 0;
>>> +}
>>> +
>>> +int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
>>> +             struct lvresize_params *lp, struct dm_list *pvh)
>>> +{
>>
>> Non-internal -> remove '_' ->  ???_lvresize
>>
>> we should probably introduce some tool prefix to make it recognizable
>
> It is my intention that this function be internal use only.  The command
> line entry point is lvresize and the liblvm entry point is
> lvm_lv_resize, both of which call _lvmresize to do the actual operation.
>   Or perhaps I'm missing something else?

Yep - lvm is using '_' for file-local static functions.
So external functions goes without underscore.

Zdenek


