From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 01 Aug 2007 17:33:42 -0400
Subject: Re: [LVM2 PATCH 2/2] lvrename: add mirrored LV support
In-Reply-To: <24987A0D-5C3A-4339-BCB8-F387BBC6A1A1@redhat.com>
References: <46AA1024.5010606@ce.jp.nec.com>
	<24987A0D-5C3A-4339-BCB8-F387BBC6A1A1@redhat.com>
Message-ID: <46B0FC36.8060604@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Jon,

Thanks for testing and reviewing.

Jonathan Brassow wrote:
>> -    if ((lv->status & MIRRORED) ||
>> -        (lv->status & MIRROR_LOG) ||
>> -        (lv->status & MIRROR_IMAGE)) {
>> -        log_error("Mirrored LV, \"%s\" cannot be renamed: %s",
>> -              lv->name, strerror(ENOSYS));
>> -        return 0;
>> -    }
>> -
> 
> I don't think you want to remove this wholesale.  Testing reveals that
> you are allowed to change a sub-lv name by itself, which is not
> something we want, I don't think.  Instead, leave the checks in for
> MIRROR_LOG and MIRROR_IMAGE.

You are right.
I didn't intend to remove the limitation.

I fixed it and modified 2 other parts:
  - Removed "Failed on <LV name>" messages from _for_each_sublv(),
    as they have no useful information.
    Callback function is responsible to put necessary info about
    failure. Added a comment about it.
  - Changed _rename_sub_lv() to return success if it can't
    determine a new name for the sub LV.
    e.g. if "lv1" is a sub LV of "lv0", renaming "lv0" will
         success without changing "lv1".
    This situation won't happen with current LVM2 code.
    But if such LVs exist, I think expected behaviour is leaving
    them unchanged and renaming others as far as possible.

Revised patch is attached.
(and fixed subject to "2/2" as it should have been)

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvrename-support-mirror.patch
Type: text/x-patch
Size: 4821 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070801/45b86bed/attachment.bin>
