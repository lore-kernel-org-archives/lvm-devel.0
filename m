From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 19 Feb 2014 11:53:57 +0100
Subject: master - cleanup: move verbose message to lv_activation_skip
In-Reply-To: <53045542.8060108@redhat.com>
References: <20140218202823.26E88602B0@fedorahosted.org>
	<53045542.8060108@redhat.com>
Message-ID: <53048D45.60709@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 19.2.2014 07:54, Marian Csontos napsal(a):
> On 02/18/2014 09:28 PM, Zdenek Kabelac wrote:
>> Gitweb:
>> http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb519c35bbfae24a26346faf2b90d2a4189e8562
>>
>> Commit:        fb519c35bbfae24a26346faf2b90d2a4189e8562
>> Parent:        fdcd95a3b3dd92ed219571467fdc235e1a6cb0b6
>> Author:        Zdenek Kabelac <zkabelac@redhat.com>
>> AuthorDate:    Tue Feb 18 20:49:32 2014 +0100
>> Committer:     Zdenek Kabelac <zkabelac@redhat.com>
>> CommitterDate: Tue Feb 18 20:49:32 2014 +0100
>>
>> cleanup: move verbose message to lv_activation_skip
>>
>> Simplify code and put verbose message into a single place.
>> ---
>>   lib/metadata/lv_manip.c |   12 ++++++------
>>   tools/lvchange.c        |    5 +----
>>   tools/vgchange.c        |    5 +----
>>   3 files changed, 8 insertions(+), 14 deletions(-)
>>
>> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
>> index 6b4c9a8..c2cc590 100644
>> --- a/lib/metadata/lv_manip.c
>> +++ b/lib/metadata/lv_manip.c
>> @@ -5675,14 +5675,14 @@ void lv_set_activation_skip(struct logical_volume
>> *lv, int override_default,
>>   int lv_activation_skip(struct logical_volume *lv, activation_change_t
>> activate,
>>                 int override_lv_skip_flag, int skip)
>>   {
>> -    /* Do not skip deactivation! */
>> -    if ((activate == CHANGE_AN) || (activate == CHANGE_ALN))
>> +    if (!(lv->status & LV_ACTIVATION_SKIP) ||
>> +        !is_change_activating(activate) || /* Do not skip deactivation */
>> +        (override_lv_skip_flag && !skip))
>>           return 0;
>>
>> -    if (override_lv_skip_flag)
>> -        return skip;
>> -
>> -    return (lv->status & LV_ACTIVATION_SKIP) ? 1 : 0;
>> +    log_verbose("ACTIVATON_SKIP flag set for LV %s/%s, skipping activation.",
>> +            lv->vg->name, lv->name);
>> +    return 1;
>
> I am not convinced this is pure "cleanup".
> When `!(lv->status & LV_ACTIVATION_SKIP)` this returns 0 and ignores
> `override_lv_skip_flag == 1 && skip == 1`.

Yep - however we never call this function with  'skip == 1' - I've committed
second patch which takes this argument away so it now should end with better
readable code.

Zdenek





