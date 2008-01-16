From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 16 Jan 2008 15:46:22 -0500
Subject: [PATCH 13/14] lvconvert should check first_seg(original_lv)
In-Reply-To: <47881C57.2070504@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com> <4788001A.60304@ce.jp.nec.com>
	<47881C57.2070504@ce.jp.nec.com>
Message-ID: <478E6D1E.1020406@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
> Jun'ichi Nomura wrote:
>> If mirror log addition/removal was requested during conversion,
>> lvconvert should manipulate on the original LV, not the top-level LV.
> 
> [13/14] lvconvert should check first_seg(original_lv)
>           lvconvert tries to add/remove log for the original LV.
>           So it should check the original LV's segment for
>           the current log type.
>           However, it checks the existing of the log for the
>           top-level LV.

The patch was incomplete.
The same change is needed for log-only addition/removal.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-mod-log-to-orig-lv.patch
Type: text/x-patch
Size: 850 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080116/813083c7/attachment.bin>
