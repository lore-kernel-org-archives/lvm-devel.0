From: Milan Broz <mbroz@redhat.com>
Date: Tue, 06 Jan 2009 18:21:17 +0100
Subject: [PATCH] Calculate mirror log size instead of hardcoding 1 extent size.
In-Reply-To: <4952F985.5010307@ce.jp.nec.com>
References: <494B82EE.7020006@redhat.com> <4952F985.5010307@ce.jp.nec.com>
Message-ID: <4963930D.5030404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
> Milan Broz wrote:
>> +		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, seg->log_lv->le_count?:1,
> 
> "seg->log_lv->le_count?:1" could be just "seg->log_lv->le_count",
> to avoid possible future confusion.
> (I.e. there is no explanation why we pass 1 when le_count is 0.)
> And if the seg->log_lv is empty, _for_each_pv() will just fail anyway
> by not finding a matching segment, regardless of len = 0 or 1.
> If it is possible to pass an empty seg->log_lv here in future,
> le_count check should be done in the above "if", I think.

Yes, thanks, I'll fix the commit.

Milan



